# =============================================================================
# Module: databases — Outputs
# =============================================================================

output "cassandra_host_internal" {
  description = "Internal Cassandra CQL host"
  value       = "cassandra.databases.svc.cluster.local"
}

output "cassandra_port" {
  description = "Cassandra CQL port"
  value       = 9042
}

output "cassandra_external" {
  description = "External Cassandra CQL access"
  value       = "localhost:${var.cassandra_nodeport}"
}

output "cassandra_user" {
  description = "Cassandra superuser"
  value       = "cassandra"
}

output "namespace" {
  description = "Kubernetes namespace"
  value       = kubernetes_namespace.databases.metadata[0].name
}
