# =============================================================================
# Module: hot-storage — Variables
# =============================================================================

variable "redis_password" {
  description = "Redis authentication password"
  type        = string
  sensitive   = true
}

variable "redis_chart_version" {
  description = "Bitnami Redis chart version"
  type        = string
}

variable "redis_memory_limit" {
  description = "Memory limit per Redis instance"
  type        = string
}

variable "redis_nodeport" {
  description = "NodePort for Redis master"
  type        = number
}
