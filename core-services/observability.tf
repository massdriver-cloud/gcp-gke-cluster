// Unless the user is running prometheus (or integrates an observability package like DD)
// there isn't much point to this service.
module "kube-state-metrics" {
  source = "../../../provisioners/terraform/modules/k8s-kube-state-metrics"

  md_metadata = var.md_metadata
  release     = "kube-state-metrics"
  namespace   = "md-observability"
}
