# =============================================================================
# Module: databases — Variables
# =============================================================================

variable "cassandra_password" {
  description = "Cassandra superuser password"
  type        = string
  sensitive   = true
}

variable "cassandra_chart_version" {
  description = "Bitnami Cassandra chart version"
  type        = string
}

variable "cassandra_heap_max" {
  description = "Max JVM heap size for Cassandra"
  type        = string
}

variable "cassandra_memory_limit" {
  description = "Container memory limit for Cassandra"
  type        = string
}

variable "cassandra_cpu_limit" {
  description = "Container CPU limit for Cassandra"
  type        = string
}

variable "cassandra_nodeport" {
  description = "NodePort for Cassandra CQL native transport"
  type        = number
}
