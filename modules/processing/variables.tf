# =============================================================================
# Module: processing — Variables
# =============================================================================

variable "spark_chart_version" {
  description = "Bitnami Spark chart version"
  type        = string
}

variable "spark_master_memory_limit" {
  description = "Memory limit for Spark master"
  type        = string
}

variable "spark_worker_memory_limit" {
  description = "Memory limit per Spark worker"
  type        = string
}

variable "spark_master_ui_nodeport" {
  description = "NodePort for Spark Master Web UI"
  type        = number
}

variable "kafka_bootstrap_internal" {
  description = "Internal Kafka bootstrap servers"
  type        = string
}

variable "cassandra_host_internal" {
  description = "Internal Cassandra host"
  type        = string
}

variable "redis_host_internal" {
  description = "Internal Redis host"
  type        = string
}
