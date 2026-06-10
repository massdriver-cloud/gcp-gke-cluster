locals {
  services = ["iam.googleapis.com", "container.googleapis.com"]
}

resource "google_project_service" "main" {
  for_each = toset(local.services)
  service  = each.value

  disable_dependent_services = false
  disable_on_destroy         = false
}
