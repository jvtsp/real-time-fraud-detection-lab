# =============================================================================
# Module: app-simulator — Variables
# =============================================================================

variable "kafka_password" {
  description = "Kafka SASL password (for producer authentication)"
  type        = string
  sensitive   = true
}

variable "kafka_bootstrap_internal" {
  description = "Internal Kafka bootstrap servers"
  type        = string
}

variable "transaction_generator_image" {
  description = "Container image for the transaction generator"
  type        = string
}

variable "transaction_rate_ms" {
  description = "Interval between generated transactions (milliseconds)"
  type        = string
}
