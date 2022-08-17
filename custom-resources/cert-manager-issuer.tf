locals {
  enable_cert_manager = length(var.core_services.cloud_dns_managed_zones) > 0

  cloud_dns_managed_zones_to_domain_map = {
    for zone in local.managed_zones :
    zone => replace(data.google_dns_managed_zone.hosted_zones[zone].name, "-", ".")
  }
  managed_zones = [for zone in var.core_services.cloud_dns_managed_zones :
    length(split("/", zone)) > 1 ? split("/", zone)[3] : zone
  ]
}

data "google_dns_managed_zone" "hosted_zones" {
  for_each = toset(local.managed_zones)
  name     = each.key
}

resource "kubernetes_manifest" "cluster_issuer" {
  count = local.enable_cert_manager ? 1 : 0
  manifest = {
    "apiVersion" = "cert-manager.io/v1",
    "kind"       = "ClusterIssuer",
    "metadata" = {
      "name" : "letsencrypt-prod"
    },
    "spec" = {
      "acme" = {
        "email" : "support+letsencrypt@massdriver.cloud"
        "server" : "https://acme-v02.api.letsencrypt.org/directory"
        "privateKeySecretRef" = {
          "name" : "letsencrypt-prod-issuer-account-key"
        },
        "solvers" = concat([for zone, name in local.cloud_dns_managed_zones_to_domain_map : {
          "selector" = {
            "dnsZones" = [
              name
            ]
          },
          "dns01" = {
            "cloudDNS" = {
              "project" : var.gcp_authentication.data.project_id,
            }
          }
          }], [ // could put other solvers here
        ])
      }
    }
  }
}
