module "alarm_channel" {
  count       = true ? 1 : 0
  source      = "github.com/massdriver-cloud/terraform-modules//k8s/alarm-channel?ref=42d293b"
  md_metadata = var.md_metadata
  namespace   = kubernetes_namespace_v1.md-observability.metadata.0.name
  release     = var.md_metadata.name_prefix

  depends_on = [module.prometheus-observability]
}

module "application_alarms" {
  count             = true ? 1 : 0
  source            = "github.com/massdriver-cloud/terraform-modules//massdriver/k8s-application-alarms?ref=42d293b"
  md_metadata       = var.md_metadata
  pod_alarms        = true
  deployment_alarms = true
  daemonset_alarms  = true

  depends_on = [module.prometheus-observability]
}
