variable "project_id" {
  description = "GCP Project ID for the VPC and K8s Cluster."
}

variable "region" {
  description = "The Region resources will be created in"
}

variable "cluster_name" {
  description = "Name of the Kubernetes Cluster to provision"
  type        = string
}

variable "node_zones" {
  description = "Zones in the region to create the cluster in"
  type        = list(any)
}
variable "cpu_min_node_count" {
  default     = "3"
  description = "Number of CPU nodes in CPU nodepool"
}

variable "cpu_max_node_count" {
  default     = "5"
  description = "Max Number of CPU nodes in CPU nodepool"
}

variable "use_cpu_spot_instances" {
  default     = false
  description = "Use Spot instance for CPU pool"
}

variable "cpu_instance_type" {
  default     = "e2-standard-8"
  description = "Machine Type for CPU node pool"
}

variable "num_cpu_nodes" {
  default     = 3
  description = "Number of CPU nodes when pool is created"
}

variable "gpu_type" {
  default     = "nvidia-l4"
  description = "GPU type"
}
variable "gpu_min_node_count" {
  default     = "0"
  description = "Min number of GPU nodes in GPU nodepool"
}

variable "gpu_max_node_count" {
  default     = "512"
  description = "Max Number of GPU nodes in GPU nodepool"
}

variable "use_gpu_spot_instances" {
  default     = false
  description = "Use Spot instance for GPU pool"
}

variable "num_gpu_nodes" {
  default     = 0
  description = "Number of GPU nodes when pool is created"
}

variable "gpu_count" {
  default     = "1"
  description = "Number of GPUs to attach to each node in GPU pool"
}

variable "gpu_instance_type" {
  default     = "g2-standard-16"
  description = "Machine Type for GPU node pool"
}

variable "gpu_instance_tags" {
  type        = list(string)
  default     = []
  description = "GPU instance nodes tags"
}
variable "disk_size_gb" {
  default = "512"
  type    = string
}

variable "gpu_operator_version" {
  default     = "v24.9.0"
  description = "Version of the GPU Operator to deploy."
}

variable "gpu_operator_driver_version" {
  type        = string
  default     = "550.127.05"
  description = "The NVIDIA Driver version deployed with GPU Operator."
}

variable "gpu_operator_namespace" {
  type        = string
  default     = "gpu-operator"
  description = "The namespace to deploy the NVIDIA GPU operator into"
}

