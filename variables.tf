# =============================================================================
# Real-Time Fraud Detection Platform — Global Variables
# =============================================================================

# -----------------------------------------------------------------------------
# Cluster
# -----------------------------------------------------------------------------
variable "cluster_name" {
  description = "Name of the Kind Kubernetes cluster"
  type        = string
  default     = "fraud-detection-platform"
}

variable "kubernetes_version" {
  description = "Kubernetes node image version (Kind)"
  type        = string
  default     = "v1.31.4"
}

# -----------------------------------------------------------------------------
# Credentials (sensitive — never hardcode in .tfvars)
# -----------------------------------------------------------------------------
variable "kafka_password" {
  description = "SASL password for Kafka authentication"
  type        = string
  sensitive   = true
}

variable "redis_password" {
  description = "Password for Redis authentication"
  type        = string
  sensitive   = true
}

variable "cassandra_password" {
  description = "Password for Cassandra superuser"
  type        = string
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Helm Chart Versions
# -----------------------------------------------------------------------------
variable "kafka_chart_version" {
  description = "Bitnami Kafka Helm chart version"
  type        = string
  default     = "32.4.3"
}

variable "redis_chart_version" {
  description = "Bitnami Redis Helm chart version"
  type        = string
  default     = "24.1.6"
}

variable "cassandra_chart_version" {
  description = "Bitnami Cassandra Helm chart version"
  type        = string
  default     = "12.3.11"
}

variable "spark_chart_version" {
  description = "Bitnami Spark Helm chart version"
  type        = string
  default     = "10.0.3"
}

variable "kafka_ui_chart_version" {
  description = "Kafka UI Helm chart version"
  type        = string
  default     = "1.6.0"
}

# -----------------------------------------------------------------------------
# Resource Limits
# -----------------------------------------------------------------------------
variable "kafka_memory_limit" {
  description = "Memory limit per Kafka broker (e.g., 1536Mi)"
  type        = string
  default     = "1536Mi"
}

variable "kafka_cpu_limit" {
  description = "CPU limit per Kafka broker"
  type        = string
  default     = "1000m"
}

variable "cassandra_heap_max" {
  description = "Max heap size for Cassandra JVM"
  type        = string
  default     = "2G"
}

variable "cassandra_memory_limit" {
  description = "Memory limit for Cassandra container"
  type        = string
  default     = "3Gi"
}

variable "cassandra_cpu_limit" {
  description = "CPU limit for Cassandra container"
  type        = string
  default     = "2000m"
}

variable "redis_memory_limit" {
  description = "Memory limit per Redis replica"
  type        = string
  default     = "512Mi"
}

variable "spark_worker_memory_limit" {
  description = "Memory limit per Spark worker"
  type        = string
  default     = "1Gi"
}

variable "spark_master_memory_limit" {
  description = "Memory limit for Spark master"
  type        = string
  default     = "512Mi"
}

# -----------------------------------------------------------------------------
# NodePort Assignments
# -----------------------------------------------------------------------------
variable "kafka_nodeport" {
  description = "NodePort for external Kafka access"
  type        = number
  default     = 30092
}

variable "kafka_ui_nodeport" {
  description = "NodePort for Kafka UI"
  type        = number
  default     = 30989
}

variable "redis_nodeport" {
  description = "NodePort for Redis"
  type        = number
  default     = 30379
}

variable "cassandra_nodeport" {
  description = "NodePort for Cassandra CQL"
  type        = number
  default     = 30942
}

variable "spark_master_ui_nodeport" {
  description = "NodePort for Spark Master Web UI"
  type        = number
  default     = 30808
}

# -----------------------------------------------------------------------------
# Application
# -----------------------------------------------------------------------------
variable "transaction_generator_image" {
  description = "Container image for the transaction generator microservice"
  type        = string
  default     = "python:3.11-slim"
}

variable "transaction_rate_ms" {
  description = "Interval in milliseconds between generated transactions"
  type        = string
  default     = "1000"
}
