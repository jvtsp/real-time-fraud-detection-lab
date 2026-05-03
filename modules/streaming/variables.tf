# =============================================================================
# Module: streaming — Variables
# =============================================================================

variable "kafka_password" {
  description = "SASL password for Kafka"
  type        = string
  sensitive   = true
}

variable "kafka_chart_version" {
  description = "Bitnami Kafka chart version"
  type        = string
}

variable "kafka_ui_chart_version" {
  description = "Kafka UI chart version"
  type        = string
}

variable "kafka_memory_limit" {
  description = "Memory limit per Kafka broker"
  type        = string
}

variable "kafka_cpu_limit" {
  description = "CPU limit per Kafka broker"
  type        = string
}

variable "kafka_nodeport" {
  description = "NodePort for external Kafka access"
  type        = number
}

variable "kafka_ui_nodeport" {
  description = "NodePort for Kafka UI"
  type        = number
}
