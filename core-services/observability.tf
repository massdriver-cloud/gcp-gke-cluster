// Unless the user is running prometheus (or integrates an observability package like DD)
// there isn't much point to this service.
module "kube-state-metrics" {
  source      = "github.com/massdriver-cloud/terraform-modules//k8s-kube-state-metrics?ref=c336d59"
  md_metadata = var.md_metadata
  release     = "kube-state-metrics"
  namespace   = "md-observability"
}

locals {
    enable_opensearch = var.observability.logging.destination == "opensearch"
    enable_fluentd     = var.observability.logging.collection == "fluentd"
}

module "opensearch" {
  count       =  local.enable_opensearch? 1 : 0
  # TODO replace ref with a SHA once k8s-opensearch is merged
  source      = "github.com/massdriver-cloud/terraform-modules//k8s-opensearch?ref=2400d29"
  md_metadata = var.md_metadata
  release     = "opensearch"
  namespace   = "md-observability" # TODO should this be monitoring?
  kubernetes_cluster =  local.kubernetes_cluster_artifact
  helm_additional_values = {
    persistence = {
        size = var.observability.logging.opensearch.persistence_size
    }
    plugins = {
        enabled = true
        installList = local.opensearch_plugins
    }
  } 
  enable_dashboards = true
  // this adds a retention policy to move indexes to warm after 1 day and delete them after a user configurable number of days
  ism_policies = {
    "hot-warm-delete": templatefile("${path.module}/logging/opensearch/ism_hot_warm_delete.json.tftpl", {"log_retention_days": var.observability.logging.opensearch.retention_days})
  }
}

module "fluentd" {
  count       = local.enable_fluentd ? 1 : 0
  # TODO replace ref with a SHA once k8s-fluentd is merged
  source      = "github.com/massdriver-cloud/terraform-modules//k8s-fluentd?ref=k8s-fluentd"
  md_metadata = var.md_metadata
  release     = "fluentd"
  namespace   = "md-observability" # TODO should this be monitoring?
  kubernetes_cluster =  local.kubernetes_cluster_artifact
  helm_additional_values = {
    "04_outputs.conf" = templatefile("${path.module}/logging/fluentd/opensearch_outputs.conf.tftpl", {
      username = local.enable_opensearch ? module.opensearch[0].opensearch_user : "opensearch"
      password = local.enable_opensearch ? module.opensearch[0].opensearch_password : "admin"
    })
  } 
}