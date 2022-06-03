locals {
  enable_cert_manager = length(var.core_services.cloud_dns_managed_zones) > 0
  enable_external_dns = length(var.core_services.cloud_dns_managed_zones) > 0
  # it's critical that the zone is the "actual" domain thing.thing.thing.thing _not_ the
  # gcp hosted zone name of thing-thing-thing-thing (thus the replace)
  cloud_dns_managed_zones_to_domain_map = {
    for zone in var.core_services.cloud_dns_managed_zones :
    zone => replace(data.google_dns_managed_zone.hosted_zones[zone].name, "-", ".")
  }
  core_services_namespace = "md-core-services"
}

data "google_dns_managed_zone" "hosted_zones" {
  for_each = toset(var.core_services.cloud_dns_managed_zones)
  name     = each.key
}

/******************************************
  Webhooks/Admission Controllers deployed to the GKE cluster,
  get called from the control plane. If the cluster has private _nodes_
  and if a webhook, etc.. get deployed to those nodes, this firewall rule is needed.
  Without this, things like cert-manager (double check) won't work
  https://github.com/kubernetes/kubernetes/issues/79739
 *****************************************/
resource "google_compute_firewall" "control_plane_ingress" {
  name        = "${var.md_metadata.name_prefix}-ingress"
  description = "Allow GKE control plane to hit pods for admission controllers/webhooks"
  project     = var.gcp_authentication.data.project_id
  network     = var.subnetwork.data.infrastructure.gcp_global_network_grn
  priority    = 1000
  direction   = "INGRESS"

  source_ranges = [var.cluster_networking.master_ipv4_cidr_block]
  source_tags   = []
  target_tags   = [local.cluster_network_tag]

  allow {
    protocol = "tcp"
    ports    = [8443]
  }
}

module "ingress_nginx" {
  source             = "../../../provisioners/terraform/modules/k8s-ingress-nginx"
  count              = var.core_services.enable_ingress ? 1 : 0
  kubernetes_cluster = local.kubernetes_cluster_artifact
  md_metadata        = var.md_metadata
  release            = "ingress-nginx"
  namespace          = local.core_services_namespace
}

module "external_dns" {
  source                  = "../../../provisioners/terraform/modules/k8s-external-dns-gcp"
  count                   = local.enable_external_dns ? 1 : 0
  kubernetes_cluster      = local.kubernetes_cluster_artifact
  md_metadata             = var.md_metadata
  release                 = "external-dns"
  namespace               = local.core_services_namespace
  cloud_dns_managed_zones = local.cloud_dns_managed_zones_to_domain_map
  gcp_project_id          = var.gcp_authentication.data.project_id
}

module "cert_manager" {
  source                  = "../../../provisioners/terraform/modules/k8s-cert-manager-gcp"
  count                   = local.enable_cert_manager ? 1 : 0
  kubernetes_cluster      = local.kubernetes_cluster_artifact
  md_metadata             = var.md_metadata
  release                 = "cert-manager"
  namespace               = local.core_services_namespace
  cloud_dns_managed_zones = local.cloud_dns_managed_zones_to_domain_map
  gcp_project_id          = var.gcp_authentication.data.project_id
}
