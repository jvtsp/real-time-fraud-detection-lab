# =============================================================================
# Module: processing — Apache Spark (Bitnami)
# =============================================================================
# Use Case: Structured Streaming jobs reading from Kafka,
#           enriching with Cassandra lookback and Redis rule checks.
# =============================================================================

# --- Namespace ---
resource "kubernetes_namespace" "processing" {
  metadata {
    name = "processing"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "platform"                     = "fraud-detection"
    }
  }
}

# --- Apache Spark ---
resource "helm_release" "spark" {
  name       = "spark"
  namespace  = kubernetes_namespace.processing.metadata[0].name
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "spark"
  version    = var.spark_chart_version
  timeout    = 600
  wait       = true

  # Topology: 1 master + 2 workers
  set {
    name  = "master.replicaCount"
    value = "1"
  }

  set {
    name  = "worker.replicaCount"
    value = "2"
  }

  # Master Resources
  set {
    name  = "master.resources.limits.memory"
    value = var.spark_master_memory_limit
  }

  set {
    name  = "master.resources.limits.cpu"
    value = "500m"
  }

  set {
    name  = "master.resources.requests.memory"
    value = "256Mi"
  }

  set {
    name  = "master.resources.requests.cpu"
    value = "100m"
  }

  # Worker Resources
  set {
    name  = "worker.resources.limits.memory"
    value = var.spark_worker_memory_limit
  }

  set {
    name  = "worker.resources.limits.cpu"
    value = "1000m"
  }

  set {
    name  = "worker.resources.requests.memory"
    value = "512Mi"
  }

  set {
    name  = "worker.resources.requests.cpu"
    value = "250m"
  }

  # Spark Master Web UI — NodePort
  set {
    name  = "master.service.type"
    value = "NodePort"
  }

  set {
    name  = "master.service.nodePorts.http"
    value = tostring(var.spark_master_ui_nodeport)
  }

  # Environment variables for Kafka + Cassandra connectivity
  set {
    name  = "master.extraEnvVars[0].name"
    value = "KAFKA_BOOTSTRAP_SERVERS"
  }

  set {
    name  = "master.extraEnvVars[0].value"
    value = var.kafka_bootstrap_internal
  }

  set {
    name  = "master.extraEnvVars[1].name"
    value = "CASSANDRA_HOST"
  }

  set {
    name  = "master.extraEnvVars[1].value"
    value = var.cassandra_host_internal
  }

  set {
    name  = "master.extraEnvVars[2].name"
    value = "REDIS_HOST"
  }

  set {
    name  = "master.extraEnvVars[2].value"
    value = var.redis_host_internal
  }

  set {
    name  = "worker.extraEnvVars[0].name"
    value = "KAFKA_BOOTSTRAP_SERVERS"
  }

  set {
    name  = "worker.extraEnvVars[0].value"
    value = var.kafka_bootstrap_internal
  }

  set {
    name  = "worker.extraEnvVars[1].name"
    value = "CASSANDRA_HOST"
  }

  set {
    name  = "worker.extraEnvVars[1].value"
    value = var.cassandra_host_internal
  }

  set {
    name  = "worker.extraEnvVars[2].name"
    value = "REDIS_HOST"
  }

  set {
    name  = "worker.extraEnvVars[2].value"
    value = var.redis_host_internal
  }
}
