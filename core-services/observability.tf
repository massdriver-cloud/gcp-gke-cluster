// Unless the user is running prometheus (or integrates an observability package like DD)
// there isn't much point to this service.
module "kube-state-metrics" {
  source      = "github.com/massdriver-cloud/terraform-modules//k8s-kube-state-metrics?ref=c336d59"
  md_metadata = var.md_metadata
  release     = "kube-state-metrics"
  namespace   = "md-observability"
}
module "opensearch" {
  count       = var.observability.logging.destination == "opensearch" ? 1 : 0
  source      = "github.com/massdriver-cloud/terraform-modules//k8s-opensearch?ref=2400d29"
  md_metadata = var.md_metadata
  release     = "opensearch"
  namespace   = "md-observability" # TODO should this be monitoring?
  kubernetes_cluster =  local.kubernetes_cluster_artifact
  helm_additional_values = {
    persistence = {
        size = var.observability.logging.opensearch.persistence_size
    }
  } 
  enable_dashboards = true
  // this adds a retention policy to move indexes to warm after 1 day and delete them after a user configurable number of days
  ism_policies = {
    "hot-warm-delete": templatefile("${path.module}/logging/opensearch/ism_hot_warm_delete.json.tftpl", {"log_retention_days": var.observability.logging.opensearch.retention_days})
  }
}
