# =============================================================================
# Module: app-simulator — Outputs
# =============================================================================

output "deployment_name" {
  description = "Name of the transaction generator deployment"
  value       = kubernetes_deployment.transaction_generator.metadata[0].name
}

output "namespace" {
  description = "Kubernetes namespace"
  value       = kubernetes_namespace.apps.metadata[0].name
}

output "kafka_topic" {
  description = "Kafka topic where transactions are published"
  value       = "transactions"
}
