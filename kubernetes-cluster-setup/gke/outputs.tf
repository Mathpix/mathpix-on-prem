output "region" {
  value       = var.region
  description = "Cluster Region"
}

output "project_id" {
  value       = var.project_id
  description = "GCP Project ID"
}

output "kubernetes_cluster_name" {
  value       = google_container_cluster.gke.name
  description = "GCP GKE Cluster Name"
}

output "get_credentials_command" {
  value       = "gcloud container clusters get-credentials ${google_container_cluster.gke.name} --region=${length(var.node_zones) == 1 ? one(var.node_zones) : var.region}"
  description = "Command to get GKE cluster credentials"
}
