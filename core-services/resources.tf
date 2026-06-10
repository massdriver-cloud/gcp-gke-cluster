
locals {
  infrastructure = {
    grn = data.google_container_cluster.cluster.id
  }

  authentication = {
    cluster = {
      server                     = local.cluster_host
      certificate-authority-data = data.google_container_cluster.cluster.master_auth.0.cluster_ca_certificate
    }
    user = {
      token = lookup(kubernetes_secret_v1.massdriver_access_token.data, "token")
    }
  }

  specs_kubernetes = {
    cloud            = "gcp"
    distribution     = "gke"
    version          = split("-", data.google_container_cluster.cluster.master_version)[0]
    platform_version = split("-", data.google_container_cluster.cluster.master_version)[1]
  }

  kubernetes_cluster_resource = {
    infrastructure = local.infrastructure
    authentication = local.authentication
    specs = {
      kubernetes = local.specs_kubernetes
    }
  }
}

resource "massdriver_resource" "kubernetes_cluster" {
  field    = "kubernetes_cluster"
  name     = "GKE Cluster Credentials ${var.md_metadata.name_prefix} [${var.subnetwork.specs.gcp.region}]"
  resource = jsonencode(local.kubernetes_cluster_resource)
}
