terraform import -var-file ../src/_connections.auto.tfvars.json -var-file ../src/_params.auto.tfvars.json kubernetes_service_account.massdriver-cloud-provisioner default/massdriver-cloud-provisioner

terraform import -var-file ../src/_connections.auto.tfvars.json -var-file ../src/_params.auto.tfvars.json google_compute_firewall.control_plane_ingress projects/md-jake-0809/global/firewalls/jake-local-dev-ingress

helm uninstall -n md-observability opensearch
helm uninstall -n md-observability opensearch-dashboards
helm uninstall -n md-observability kube-state-metrics
helm uninstall -n md-observability fluentbit
