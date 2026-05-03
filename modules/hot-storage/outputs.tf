# =============================================================================
# Module: hot-storage — Outputs
# =============================================================================

output "redis_host_internal" {
  description = "Internal Redis master host (for in-cluster clients)"
  value       = "redis-master.hot-storage.svc.cluster.local"
}

output "redis_port" {
  description = "Redis port"
  value       = 6379
}

output "redis_sentinel_host" {
  description = "Redis Sentinel host (for HA-aware clients)"
  value       = "redis.hot-storage.svc.cluster.local"
}

output "redis_external" {
  description = "External Redis access"
  value       = "localhost:${var.redis_nodeport}"
}

output "namespace" {
  description = "Kubernetes namespace"
  value       = kubernetes_namespace.hot_storage.metadata[0].name
}
