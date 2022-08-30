locals {
  enable_opensearch = var.observability.logging.destination == "opensearch"
  enable_fluentbit  = var.observability.logging.collection == "fluentbit"
  o11y_namespace    = "md-observability"
  fluent_pw_raw = random_password.fluentbit_opensearch_password.result
  // cost of 12 because that's what the opensearch security hash.sh utility uses
  // see: https://github.com/opensearch-project/security/blob/main/src/main/java/org/opensearch/security/tools/Hasher.java#L81
  fluent_pw_hash = bcrypt(local.fluent_pw_raw, 12)
}
resource "random_password" "fluentbit_opensearch_password" {
  length = 16
  special = false
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
#   source             = "github.com/massdriver-cloud/terraform-modules//k8s-opensearch?ref=k8s-opensearch-update"
  source             = "github.com/massdriver-cloud/terraform-modules//k8s-opensearch?ref=main"
  md_metadata        = var.md_metadata
  release            = "opensearch"
  namespace          = local.o11y_namespace
  kubernetes_cluster = local.kubernetes_cluster_artifact
  helm_additional_values = {
    persistence = {
      size = var.observability.logging.opensearch.persistence_size
    }
    securityConfig = {
      config = {
        data = {
          "internal_users.yml" : templatefile("${path.module}/logging/opensearch/internal_users.yml.tftpl", {
            password =  local.fluent_pw_hash
        })
        }
      }
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
        username  = "fluentbit"
        password  = local.fluent_pw_raw
        namespace = local.o11y_namespace
      })
    }
  }
}
