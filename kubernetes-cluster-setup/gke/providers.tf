provider "kubernetes" {
  host  = "https://${google_container_cluster.gke.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.gke.master_auth.0.cluster_ca_certificate,
  )
}

provider "helm" {
  kubernetes {
    token = data.google_client_config.provider.access_token
    host  = "https://${google_container_cluster.gke.endpoint}"
    cluster_ca_certificate = base64decode(
      google_container_cluster.gke.master_auth.0.cluster_ca_certificate,
    )
  }
}
