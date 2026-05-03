# =============================================================================
# Real-Time Fraud Detection Platform — Outputs
# =============================================================================

# --- Access URLs ---
output "kafka_external" {
  description = "External Kafka bootstrap server"
  value       = module.streaming.kafka_bootstrap_external
}

output "kafka_ui_url" {
  description = "Kafka UI Web Interface"
  value       = module.streaming.kafka_ui_url
}

output "redis_external" {
  description = "External Redis access"
  value       = module.hot_storage.redis_external
}

output "cassandra_external" {
  description = "External Cassandra CQL access"
  value       = module.databases.cassandra_external
}

output "spark_master_url" {
  description = "Spark Master Web UI"
  value       = module.processing.spark_master_url
}

# --- Credentials ---
output "kafka_sasl_user" {
  description = "Kafka SASL username"
  value       = module.streaming.kafka_sasl_user
}

output "cassandra_user" {
  description = "Cassandra superuser"
  value       = module.databases.cassandra_user
}

# --- Application ---
output "transaction_generator_deployment" {
  description = "Transaction generator deployment name"
  value       = module.app_simulator.deployment_name
}

output "transaction_topic" {
  description = "Kafka topic for transactions"
  value       = module.app_simulator.kafka_topic
}

# --- Quick Start ---
output "access_summary" {
  description = "Quick access summary"
  value       = <<-EOT

  ╔══════════════════════════════════════════════════════════════╗
  ║         FRAUD DETECTION PLATFORM — ACCESS SUMMARY          ║
  ╠══════════════════════════════════════════════════════════════╣
  ║                                                            ║
  ║  Kafka UI:        ${module.streaming.kafka_ui_url}              ║
  ║  Kafka External:  ${module.streaming.kafka_bootstrap_external}                  ║
  ║  Spark Master:    ${module.processing.spark_master_url}              ║
  ║  Redis:           ${module.hot_storage.redis_external}                  ║
  ║  Cassandra CQL:   ${module.databases.cassandra_external}                  ║
  ║                                                            ║
  ║  TX Generator:    kubectl logs -n apps -l app=transaction-generator ║
  ║                                                            ║
  ╚══════════════════════════════════════════════════════════════╝

  EOT
}
