# =============================================================================
# Module: hot-storage — Redis (Bitnami, Sentinel Mode)
# =============================================================================
# Use Case: Storing temporary fraud rules
#   e.g., SET card:X:blocked true EX 600  →  "Block card X for 10 mins"
# =============================================================================

# --- Namespace ---
resource "kubernetes_namespace" "hot_storage" {
  metadata {
    name = "hot-storage"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "platform"                     = "fraud-detection"
    }
  }
}

# --- Redis Credentials (Secret) ---
resource "kubernetes_secret" "redis_credentials" {
  metadata {
    name      = "redis-credentials"
    namespace = kubernetes_namespace.hot_storage.metadata[0].name
  }

  data = {
    "redis-password" = var.redis_password
  }

  type = "Opaque"
}

# --- Redis (Sentinel Mode) ---
resource "helm_release" "redis" {
  name       = "redis"
  namespace  = kubernetes_namespace.hot_storage.metadata[0].name
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "redis"
  version    = var.redis_chart_version
  timeout    = 600
  wait       = true

  # Architecture: Sentinel (HA)
  set {
    name  = "architecture"
    value = "replication"
  }

  set {
    name  = "sentinel.enabled"
    value = "true"
  }

  # Authentication
  set {
    name  = "auth.enabled"
    value = "true"
  }

  set {
    name  = "auth.existingSecret"
    value = kubernetes_secret.redis_credentials.metadata[0].name
  }

  set {
    name  = "auth.existingSecretPasswordKey"
    value = "redis-password"
  }

  # Replicas
  set {
    name  = "replica.replicaCount"
    value = "2"
  }

  set {
    name  = "sentinel.quorum"
    value = "2"
  }

  # Resource Limits — Master
  set {
    name  = "master.resources.limits.memory"
    value = var.redis_memory_limit
  }

  set {
    name  = "master.resources.limits.cpu"
    value = "500m"
  }

  set {
    name  = "master.resources.requests.memory"
    value = "128Mi"
  }

  set {
    name  = "master.resources.requests.cpu"
    value = "100m"
  }

  # Resource Limits — Replicas
  set {
    name  = "replica.resources.limits.memory"
    value = var.redis_memory_limit
  }

  set {
    name  = "replica.resources.limits.cpu"
    value = "500m"
  }

  set {
    name  = "replica.resources.requests.memory"
    value = "128Mi"
  }

  set {
    name  = "replica.resources.requests.cpu"
    value = "100m"
  }

  # Sentinel Resources
  set {
    name  = "sentinel.resources.limits.memory"
    value = "128Mi"
  }

  set {
    name  = "sentinel.resources.limits.cpu"
    value = "200m"
  }

  # Service — NodePort
  set {
    name  = "master.service.type"
    value = "NodePort"
  }

  set {
    name  = "master.service.nodePorts.redis"
    value = tostring(var.redis_nodeport)
  }

  # Persistence
  set {
    name  = "master.persistence.size"
    value = "2Gi"
  }

  set {
    name  = "replica.persistence.size"
    value = "2Gi"
  }
}
