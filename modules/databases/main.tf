# =============================================================================
# Module: databases — Apache Cassandra (Bitnami)
# =============================================================================
# Use Case: Wide-column historical storage for user transaction history
#            and pattern analysis (fraud detection lookback).
# =============================================================================

# --- Namespace ---
resource "kubernetes_namespace" "databases" {
  metadata {
    name = "databases"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "platform"                     = "fraud-detection"
    }
  }
}

# --- Cassandra Credentials (Secret) ---
resource "kubernetes_secret" "cassandra_credentials" {
  metadata {
    name      = "cassandra-credentials"
    namespace = kubernetes_namespace.databases.metadata[0].name
  }

  data = {
    "cassandra-password" = var.cassandra_password
  }

  type = "Opaque"
}

# --- Apache Cassandra ---
resource "helm_release" "cassandra" {
  name       = "cassandra"
  namespace  = kubernetes_namespace.databases.metadata[0].name
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "cassandra"
  version    = var.cassandra_chart_version
  timeout    = 900
  wait       = true

  # Single node for local simulation
  set {
    name  = "replicaCount"
    value = "1"
  }

  # Authentication
  set {
    name  = "dbUser.user"
    value = "cassandra"
  }

  set {
    name  = "dbUser.existingSecret"
    value = kubernetes_secret.cassandra_credentials.metadata[0].name
  }

  # JVM Heap — capped at 2GB to prevent OOM kills
  set {
    name  = "jvm.maxHeapSize"
    value = var.cassandra_heap_max
  }

  set {
    name  = "jvm.newHeapSize"
    value = "512M"
  }

  # Resource Limits
  set {
    name  = "resources.limits.memory"
    value = var.cassandra_memory_limit
  }

  set {
    name  = "resources.limits.cpu"
    value = var.cassandra_cpu_limit
  }

  set {
    name  = "resources.requests.memory"
    value = "1Gi"
  }

  set {
    name  = "resources.requests.cpu"
    value = "500m"
  }

  # Cluster settings
  set {
    name  = "cluster.name"
    value = "fraud-detection-cluster"
  }

  set {
    name  = "cluster.datacenter"
    value = "dc1"
  }

  # Service — NodePort
  set {
    name  = "service.type"
    value = "NodePort"
  }

  set {
    name  = "service.nodePorts.cql"
    value = tostring(var.cassandra_nodeport)
  }

  # Persistence
  set {
    name  = "persistence.size"
    value = "8Gi"
  }

  # Network policies (disabled for local)
  set {
    name  = "networkPolicy.enabled"
    value = "false"
  }
}
