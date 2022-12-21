module "gcp-gke-custom-resources" {
  source = "../../terraform-modules/gcp-gke-custom-resources"
  md_metadata = var.md_metadata
  gcp_project_id = var.gcp_authentication.data.project_id
  cloud_dns_managed_zones = var.core_services.cloud_dns_managed_zones
}
