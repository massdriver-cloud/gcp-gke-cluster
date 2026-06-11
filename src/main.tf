locals {
  cluster_name        = var.md_metadata.name_prefix
  cluster_network_tag = "gke-${local.cluster_name}"
}

// https://github.com/terraform-google-modules/terraform-google-kubernetes-engine
resource "google_container_cluster" "cluster" {
  name            = local.cluster_name
  resource_labels = var.md_metadata.default_tags
  location        = var.subnetwork.specs.gcp.region

  # Massdriver manages the full cluster lifecycle, including decommissioning.
  # The google provider defaults this to true (v5+), which blocks `terraform destroy`.
  deletion_protection = false

  release_channel {
    channel = "STABLE"
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  # SECURITY
  workload_identity_config {
    workload_pool = "${var.gcp_authentication.project_id}.svc.id.goog"
  }
  enable_shielded_nodes = true

  # NETWORKING
  network                     = var.subnetwork.infrastructure.gcp_global_network_grn
  subnetwork                  = var.subnetwork.infrastructure.grn
  networking_mode             = "VPC_NATIVE"
  default_max_pods_per_node   = 32
  enable_intranode_visibility = true
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.cluster_networking.cluster_ipv4_cidr_block
    services_ipv4_cidr_block = var.cluster_networking.services_ipv4_cidr_block
  }
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.cluster_networking.master_ipv4_cidr_block
  }

  # UPGRADES, REPAIR AND MAINTENANCE (managed in Node pools)

  # AUTHENTICATION CREDENTIALS (workload identity above in security)

  # SCALING
  # I think the fact this block is called this is hella misleading
  # This auto-provisons nodes, they aren't known machine types, GKE chooses them
  cluster_autoscaling {
    enabled = false
  }

  # LOGGING
  # *_service and *_config cannot be used together
  # we can turn on more by using the config, to get logs and metrics
  # for workloads that are non-system aka customer workloads
  # logging_service = "logging.googleapis.com/kubernetes"
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  # MONITORING
  # monitoring_service = "monitoring.googleapis.com/kubernetes"
  # The GKE components exposing logs.
  # https://cloud.google.com/stackdriver/docs/solutions/gke/installing#available-metrics
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }
  # https://github.com/hashicorp/terraform-provider-google/issues/10820
  # mutually exclustive with *_service above
  # cluster_telemetry {
  #   type = "ENABLED"
  # }

  # CLUSTER ADD-ONS
  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }
    http_load_balancing {
      disabled = false
    }
    dns_cache_config {
      enabled = true
    }
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
  }

  lifecycle {
    ignore_changes = [node_pool, initial_node_count, resource_labels["asmv"], resource_labels["mesh_id"]]
  }

  # CIS GKE V1.1 6.6.3
  # pod_security_policy_config {
  #   enabled = true
  # }

  # container.googleapis.com must be enabled before the cluster is created.
  depends_on = [
    google_project_service.main,
    google_service_account.nodes
  ]
}

resource "google_container_node_pool" "nodes" {
  for_each = { for ng in var.node_groups : ng.name => ng }
  name     = each.value.name
  cluster  = google_container_cluster.cluster.id

  depends_on = [
    google_service_account.nodes,
    google_project_iam_member.nodes_service_account-log_writer,
    google_project_iam_member.nodes_service_account-metric_writer,
    google_project_iam_member.nodes_service_account-monitoring_viewer,
    google_project_iam_member.nodes_service_account-resourceMetadata-writer,
    google_project_iam_member.nodes_service_account-gcr,
    google_project_iam_member.nodes_service_account-artifact-registry
  ]

  node_config {
    machine_type = each.value.machine_type
    spot         = each.value.is_spot

    # IMAGE TYPE
    # Pre-configured: Container-Optimized OS with containerd
    image_type = "COS_CONTAINERD"

    # IMAGE STREAMING
    # Stream container images from Artifact Registry so pods can start before the
    # full image is pulled. Significantly faster cold starts for large images.
    gcfs_config {
      enabled = true
    }
    # https://cloud.google.com/kubernetes-engine/docs/how-to/tags?authuser=2&_ga=2.262509772.-1752412165.1643829903#overview
    # Organize GKE resources to track usage and billing.
    labels = var.md_metadata.default_tags
    # Conditionally allow or deny requests based on the tag.
    tags = [local.cluster_network_tag]

    metadata = merge(
      { "cluster_name" = var.md_metadata.name_prefix },
      { "node_pool" = each.value.name },
      {
        "disable-legacy-endpoints" = true
      },
    )

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.nodes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  # UPGRADES, REPAIR, AND MAINTENANCE
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  upgrade_settings {
    max_surge       = 5
    max_unavailable = 0
  }

  # This is the "traditional" auto-scaling
  # see the cluster_autoscaling block above
  autoscaling {
    min_node_count = each.value.min_size
    max_node_count = each.value.max_size
  }

  // if we don't this value (initial_node_count), the node group will be stuck at 0 nodes and refuse to scale.
  // DO NOT CHANGE THIS VALUE OR EXPOSE IT TO A USER. Changing the initial_node_count recreates the resource:
  // https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool#initial_node_count
  initial_node_count = 1
  lifecycle {
    ignore_changes = [
      initial_node_count,
      node_config[0].resource_labels,
      node_config[0].kubelet_config
    ]
    # bring up new node pools before removing existing
    create_before_destroy = true
  }
}
