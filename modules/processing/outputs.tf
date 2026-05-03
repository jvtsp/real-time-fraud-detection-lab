# =============================================================================
# Module: processing — Outputs
# =============================================================================

output "spark_master_url" {
  description = "Spark Master Web UI URL"
  value       = "http://localhost:${var.spark_master_ui_nodeport}"
}

output "spark_master_internal" {
  description = "Internal Spark master endpoint (for spark-submit)"
  value       = "spark://spark-master-svc.processing.svc.cluster.local:7077"
}

output "namespace" {
  description = "Kubernetes namespace"
  value       = kubernetes_namespace.processing.metadata[0].name
}
