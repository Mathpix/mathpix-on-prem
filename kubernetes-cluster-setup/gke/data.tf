data "google_client_config" "provider" {}

data "google_container_engine_versions" "latest" {
  provider = google
  location = var.region
  project  = var.project_id
}
