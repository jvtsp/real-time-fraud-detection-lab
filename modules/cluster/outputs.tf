# =============================================================================
# Module: cluster — Outputs
# =============================================================================

output "endpoint" {
  description = "Kubernetes API server endpoint"
  value       = kind_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate (base64-decoded)"
  value       = kind_cluster.this.cluster_ca_certificate
}

output "client_certificate" {
  description = "Client certificate for authentication"
  value       = kind_cluster.this.client_certificate
}

output "client_key" {
  description = "Client key for authentication"
  value       = kind_cluster.this.client_key
  sensitive   = true
}

output "kubeconfig" {
  description = "Full kubeconfig content"
  value       = kind_cluster.this.kubeconfig
  sensitive   = true
}
