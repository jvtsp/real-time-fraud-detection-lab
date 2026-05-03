# =============================================================================
# Real-Time Fraud Detection Platform — Root Module
# =============================================================================
# Orchestrates all infrastructure modules in dependency order.
# =============================================================================

# --- 1. Kubernetes Cluster (Kind) ---
module "cluster" {
  source = "./modules/cluster"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version

  nodeport_mappings = [
    var.kafka_nodeport,
    var.kafka_nodeport + 1,
    var.kafka_nodeport + 2,
    var.kafka_ui_nodeport,
    var.redis_nodeport,
    var.cassandra_nodeport,
    var.spark_master_ui_nodeport,
  ]
}

# --- 2. Streaming Layer (Kafka + Kafka UI) ---
module "streaming" {
  source = "./modules/streaming"

  kafka_password         = var.kafka_password
  kafka_chart_version    = var.kafka_chart_version
  kafka_ui_chart_version = var.kafka_ui_chart_version
  kafka_memory_limit     = var.kafka_memory_limit
  kafka_cpu_limit        = var.kafka_cpu_limit
  kafka_nodeport         = var.kafka_nodeport
  kafka_ui_nodeport      = var.kafka_ui_nodeport

  depends_on = [module.cluster]
}

# --- 3. Hot Storage (Redis Sentinel) ---
module "hot_storage" {
  source = "./modules/hot-storage"

  redis_password      = var.redis_password
  redis_chart_version = var.redis_chart_version
  redis_memory_limit  = var.redis_memory_limit
  redis_nodeport      = var.redis_nodeport

  depends_on = [module.cluster]
}

# --- 4. Historical Storage (Cassandra) ---
module "databases" {
  source = "./modules/databases"

  cassandra_password      = var.cassandra_password
  cassandra_chart_version = var.cassandra_chart_version
  cassandra_heap_max      = var.cassandra_heap_max
  cassandra_memory_limit  = var.cassandra_memory_limit
  cassandra_cpu_limit     = var.cassandra_cpu_limit
  cassandra_nodeport      = var.cassandra_nodeport

  depends_on = [module.cluster]
}

# --- 5. Processing Engine (Spark) ---
module "processing" {
  source = "./modules/processing"

  spark_chart_version       = var.spark_chart_version
  spark_master_memory_limit = var.spark_master_memory_limit
  spark_worker_memory_limit = var.spark_worker_memory_limit
  spark_master_ui_nodeport  = var.spark_master_ui_nodeport
  kafka_bootstrap_internal  = module.streaming.kafka_bootstrap_internal
  cassandra_host_internal   = module.databases.cassandra_host_internal
  redis_host_internal       = module.hot_storage.redis_host_internal

  depends_on = [
    module.streaming,
    module.databases,
    module.hot_storage,
  ]
}

# --- 6. Application Simulator (Transaction Generator) ---
module "app_simulator" {
  source = "./modules/app-simulator"

  kafka_password              = var.kafka_password
  kafka_bootstrap_internal    = module.streaming.kafka_bootstrap_internal
  transaction_generator_image = var.transaction_generator_image
  transaction_rate_ms         = var.transaction_rate_ms

  depends_on = [module.streaming]
}
