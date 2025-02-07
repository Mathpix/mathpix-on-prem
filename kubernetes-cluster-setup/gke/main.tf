# GKE Configuration
resource "google_container_cluster" "gke" {
  name     = var.cluster_name
  project  = var.project_id
  location = length(var.node_zones) == 1 ? one(var.node_zones) : var.region

  min_master_version = "1.30"
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.gke-vpc[0].name
  subnetwork = google_compute_subnetwork.gke-subnet[0].name
  
  deletion_protection = false

  # Workload Identity Configuration
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  release_channel {
    channel = "REGULAR"
  }

  # Ensure VPC and subnet exist before creating the GKE cluster
  depends_on = [
    google_compute_network.gke-vpc,
    google_compute_subnetwork.gke-subnet
  ]
}

# CPU Node Pool
resource "google_container_node_pool" "cpu_nodes" {
  name           = "${var.cluster_name}-cpu-pool"
  project        = var.project_id
  location       = length(var.node_zones) == 1 ? one(var.node_zones) : var.region
  node_locations = length(var.node_zones) > 1 ? var.node_zones : null
  cluster        = google_container_cluster.gke.name
  node_count     = var.num_cpu_nodes
  autoscaling {
    min_node_count = var.cpu_min_node_count
    max_node_count = var.cpu_max_node_count
  }
  node_config {
    image_type = "UBUNTU_CONTAINERD"
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/compute"
    ]

    preemptible  = var.use_cpu_spot_instances
    machine_type = var.cpu_instance_type
    disk_size_gb = var.disk_size_gb
    tags         = concat(["tf-managed", "${var.cluster_name}"], var.gpu_instance_tags)
    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      part_of    = var.cluster_name
      env        = var.project_id
      managed_by = "terraform"
    }
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

# GPU Node Pool
resource "google_container_node_pool" "gpu_nodes" {
  name           = "${var.cluster_name}-gpu-pool"
  project        = var.project_id
  location       = length(var.node_zones) == 1 ? one(var.node_zones) : var.region
  node_locations = length(var.node_zones) > 1 ? var.node_zones : null
  cluster        = google_container_cluster.gke.name
  node_count     = var.num_gpu_nodes
  autoscaling {
    min_node_count = var.gpu_min_node_count
    max_node_count = var.gpu_max_node_count
  }
  node_config {
    image_type = "UBUNTU_CONTAINERD"
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/compute"
    ]
    guest_accelerator {
      type  = var.gpu_type
      count = var.gpu_count
      gpu_driver_installation_config {
        gpu_driver_version = "INSTALLATION_DISABLED"
      }
    }

    preemptible  = var.use_gpu_spot_instances
    machine_type = var.gpu_instance_type
    disk_size_gb = var.disk_size_gb
    tags         = concat(["tf-managed", "${var.cluster_name}"], var.gpu_instance_tags)
    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      part_of    = var.cluster_name
      env        = var.project_id
      managed_by = "terraform"
    }
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
  timeouts {
    create = "30m"
    update = "30m"
  }
}


# VPC Configuration
resource "google_compute_network" "gke-vpc" {
  count                   = 1
  name                    = "${var.cluster_name}-vpc"
  auto_create_subnetworks = "false"
  project                 = var.project_id
}

# Subnet Configuration
resource "google_compute_subnetwork" "gke-subnet" {
  name          = "${var.cluster_name}-subnet"
  count         = 1
  region        = var.region
  network       = google_compute_network.gke-vpc[0].name
  ip_cidr_range = "10.150.0.0/20"
  project       = var.project_id
}


# GPU Operator Namespace
resource "kubernetes_namespace_v1" "gpu-operator" {
  metadata {
    annotations = {
      name = "gpu-operator"
    }

    labels = {
      cluster    = var.cluster_name
      managed_by = "terraform"
    }

    name = var.gpu_operator_namespace
  }
}

# GPU Operator Resource Quota
resource "kubernetes_resource_quota_v1" "gpu-operator-quota" {
  depends_on = [google_container_node_pool.gpu_nodes, kubernetes_namespace_v1.gpu-operator]
  metadata {
    name      = "gpu-operator-quota"
    namespace = var.gpu_operator_namespace
  }
  spec {
    hard = {
      pods = 1024
    }
    scope_selector {
      match_expression {
        operator   = "In"
        scope_name = "PriorityClass"
        values     = ["system-node-critical", "system-cluster-critical"]
      }
    }
  }
}

# GPU Operator Configuration
resource "helm_release" "gpu-operator" {
  depends_on       = [google_container_node_pool.gpu_nodes, kubernetes_resource_quota_v1.gpu-operator-quota, kubernetes_namespace_v1.gpu-operator]
  count            = 1
  name             = "gpu-operator"
  repository       = "https://helm.ngc.nvidia.com/nvidia"
  chart            = "gpu-operator"
  version          = var.gpu_operator_version
  namespace        = var.gpu_operator_namespace
  create_namespace = false
  atomic           = true
  cleanup_on_fail  = true
  reset_values     = true
  replace          = true

  set {
    name  = "driver.version"
    value = var.gpu_operator_driver_version
  }

  # Increase GPU Operator Resource Limits
  set {
    name  = "operator.resources.requests.cpu"
    value = "2000m"
  }

  set {
    name  = "operator.resources.requests.memory"
    value = "2048Mi"
  }

  set {
    name  = "operator.resources.limits.cpu"
    value = "4000m"
  }

  set {
    name  = "operator.resources.limits.memory"
    value = "4096Mi"
  }
}
