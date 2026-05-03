# =============================================================================
# Module: streaming — Apache Kafka (Bitnami) + Kafka UI (Provectus)
# =============================================================================

# --- Namespace ---
resource "kubernetes_namespace" "streaming" {
  metadata {
    name = "streaming"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "platform"                     = "fraud-detection"
    }
  }
}

# --- Kafka SASL Credentials (Secret) ---
resource "kubernetes_secret" "kafka_credentials" {
  metadata {
    name      = "kafka-credentials"
    namespace = kubernetes_namespace.streaming.metadata[0].name
  }

  data = {
    "client-passwords" = var.kafka_password
  }

  type = "Opaque"
}

# --- Apache Kafka (Bitnami — KRaft Mode) ---
resource "helm_release" "kafka" {
  name       = "kafka"
  namespace  = kubernetes_namespace.streaming.metadata[0].name
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "kafka"
  version    = var.kafka_chart_version
  timeout    = 900
  wait       = true

  # KRaft mode (no Zookeeper)
  set {
    name  = "kraft.enabled"
    value = "true"
  }

  # Broker configuration
  set {
    name  = "broker.replicaCount"
    value = "3"
  }

  set {
    name  = "controller.replicaCount"
    value = "1"
  }

  # SASL Authentication
  set {
    name  = "auth.clientProtocol"
    value = "sasl"
  }

  set {
    name  = "auth.interBrokerProtocol"
    value = "plaintext"
  }

  set {
    name  = "auth.sasl.mechanisms"
    value = "PLAIN"
  }

  set {
    name  = "auth.sasl.interBrokerMechanism"
    value = "PLAIN"
  }

  set_sensitive {
    name  = "auth.sasl.client.passwords"
    value = var.kafka_password
  }

  set {
    name  = "auth.sasl.client.users"
    value = "fraud-platform"
  }

  # Resource Limits
  set {
    name  = "broker.resources.limits.memory"
    value = var.kafka_memory_limit
  }

  set {
    name  = "broker.resources.limits.cpu"
    value = var.kafka_cpu_limit
  }

  set {
    name  = "broker.resources.requests.memory"
    value = "512Mi"
  }

  set {
    name  = "broker.resources.requests.cpu"
    value = "250m"
  }

  # External Access (NodePort for producers outside the cluster)
  set {
    name  = "externalAccess.enabled"
    value = "true"
  }

  set {
    name  = "externalAccess.broker.service.type"
    value = "NodePort"
  }

  set {
    name  = "externalAccess.broker.service.nodePorts[0]"
    value = tostring(var.kafka_nodeport)
  }

  set {
    name  = "externalAccess.broker.service.nodePorts[1]"
    value = tostring(var.kafka_nodeport + 1)
  }

  set {
    name  = "externalAccess.broker.service.nodePorts[2]"
    value = tostring(var.kafka_nodeport + 2)
  }

  # Persistence
  set {
    name  = "broker.persistence.size"
    value = "5Gi"
  }

  # Listeners
  set {
    name  = "listeners.client.protocol"
    value = "SASL_PLAINTEXT"
  }

  set {
    name  = "listeners.external.protocol"
    value = "SASL_PLAINTEXT"
  }
}

# --- Kafka UI (Kafbat — formerly Provectus) ---
resource "helm_release" "kafka_ui" {
  name       = "kafka-ui"
  namespace  = kubernetes_namespace.streaming.metadata[0].name
  repository = "https://kafbat.github.io/helm-charts"
  chart      = "kafka-ui"
  version    = var.kafka_ui_chart_version
  timeout    = 600
  wait       = true

  depends_on = [helm_release.kafka]

  # Kafka cluster connection
  set {
    name  = "yamlApplicationConfig.kafka.clusters[0].name"
    value = "fraud-detection-kafka"
  }

  set {
    name  = "yamlApplicationConfig.kafka.clusters[0].bootstrapServers"
    value = "kafka-broker-0.kafka-broker-headless.streaming.svc.cluster.local:9092\\,kafka-broker-1.kafka-broker-headless.streaming.svc.cluster.local:9092\\,kafka-broker-2.kafka-broker-headless.streaming.svc.cluster.local:9092"
  }

  set {
    name  = "yamlApplicationConfig.kafka.clusters[0].properties.security\\.protocol"
    value = "SASL_PLAINTEXT"
  }

  set {
    name  = "yamlApplicationConfig.kafka.clusters[0].properties.sasl\\.mechanism"
    value = "PLAIN"
  }

  set_sensitive {
    name  = "yamlApplicationConfig.kafka.clusters[0].properties.sasl\\.jaas\\.config"
    value = "org.apache.kafka.common.security.plain.PlainLoginModule required username=\"fraud-platform\" password=\"${var.kafka_password}\";"
  }

  # Service — NodePort
  set {
    name  = "service.type"
    value = "NodePort"
  }

  set {
    name  = "service.nodePort"
    value = tostring(var.kafka_ui_nodeport)
  }

  # Resources
  set {
    name  = "resources.limits.memory"
    value = "512Mi"
  }

  set {
    name  = "resources.limits.cpu"
    value = "500m"
  }

  set {
    name  = "resources.requests.memory"
    value = "256Mi"
  }

  set {
    name  = "resources.requests.cpu"
    value = "100m"
  }
}
