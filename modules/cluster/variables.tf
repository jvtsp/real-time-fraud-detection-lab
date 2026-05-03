# =============================================================================
# Module: cluster — Variables
# =============================================================================

variable "cluster_name" {
  description = "Name of the Kind cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes node image version"
  type        = string
}

variable "nodeport_mappings" {
  description = "List of NodePort values to map from container to host"
  type        = list(number)
}
