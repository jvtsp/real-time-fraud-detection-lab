# =============================================================================
# Module: streaming — Outputs
# =============================================================================

output "kafka_bootstrap_internal" {
  description = "Internal Kafka bootstrap servers (for in-cluster consumers)"
  value       = "kafka-broker-0.kafka-broker-headless.streaming.svc.cluster.local:9092,kafka-broker-1.kafka-broker-headless.streaming.svc.cluster.local:9092,kafka-broker-2.kafka-broker-headless.streaming.svc.cluster.local:9092"
}

output "kafka_bootstrap_external" {
  description = "External Kafka bootstrap server (for producers outside the cluster)"
  value       = "localhost:${var.kafka_nodeport}"
}

output "kafka_ui_url" {
  description = "Kafka UI access URL"
  value       = "http://localhost:${var.kafka_ui_nodeport}"
}

output "kafka_sasl_user" {
  description = "Kafka SASL username"
  value       = "fraud-platform"
}

output "namespace" {
  description = "Kubernetes namespace for streaming resources"
  value       = kubernetes_namespace.streaming.metadata[0].name
}
