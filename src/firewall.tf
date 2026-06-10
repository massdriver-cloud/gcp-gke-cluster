/******************************************
  Admission controller / webhook backends deployed into the cluster are called
  by the control plane. With private nodes, the control plane CIDR can't reach
  pods on custom webhook ports unless explicitly allowed. This rule opens 8443
  from the control plane to the nodes so any admission webhooks function.
  https://github.com/kubernetes/kubernetes/issues/79739
 *****************************************/
resource "google_compute_firewall" "control_plane_ingress" {
  name        = "${var.md_metadata.name_prefix}-webhook"
  description = "Allow GKE control plane to hit pods for admission controllers/webhooks"
  project     = var.gcp_authentication.project_id
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
