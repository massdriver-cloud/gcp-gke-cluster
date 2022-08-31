locals {
  enable_opensearch = var.observability.logging.destination == "opensearch"
  enable_fluentbit  = var.observability.logging.collection == "fluentbit"
  o11y_namespace    = "md-observability"
}

// Unless the user is running prometheus (or integrates an observability package like DD)
// there isn't much point to this service.
module "kube-state-metrics" {
  source      = "github.com/massdriver-cloud/terraform-modules//k8s-kube-state-metrics?ref=c336d59"
  md_metadata = var.md_metadata
  release     = "kube-state-metrics"
  namespace   = local.o11y_namespace
}

module "opensearch" {
  count              = local.enable_opensearch ? 1 : 0
  source             = "github.com/massdriver-cloud/terraform-modules//k8s-opensearch?ref=5fc9525"
  md_metadata        = var.md_metadata
  release            = "opensearch"
  namespace          = local.o11y_namespace
  kubernetes_cluster = local.kubernetes_cluster_artifact
  helm_additional_values = {
    persistence = {
      size = var.observability.logging.opensearch.persistence_size
    }
  }
  enable_dashboards = true
  // this adds a retention policy to move indexes to warm after 1 day and delete them after a user configurable number of days
  ism_policies = {
    "hot-warm-delete" : templatefile("${path.module}/logging/opensearch/ism_hot_warm_delete.json.tftpl", { "log_retention_days" : var.observability.logging.opensearch.retention_days })
  }
}

module "fluentbit" {
  count = local.enable_fluentbit ? 1 : 0
  # TODO replace ref with a SHA once k8s-fluentbit is merged
  source             = "github.com/massdriver-cloud/terraform-modules//k8s-fluentbit?ref=k8s-fluentbit"
  md_metadata        = var.md_metadata
  release            = "fluentbit"
  namespace          = local.o11y_namespace
  kubernetes_cluster = local.kubernetes_cluster_artifact
  helm_additional_values = {
    config = {
      outputs = templatefile("${path.module}/logging/fluentbit/opensearch_output.conf.tftpl", {
        namespace = local.o11y_namespace
      })
    }
  }
}
