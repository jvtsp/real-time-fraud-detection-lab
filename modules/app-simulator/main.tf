# =============================================================================
# Module: app-simulator — Transaction Generator Microservice
# =============================================================================
# Deploys a lightweight Python-based Deployment that generates mock JSON
# transaction data and pushes it to the Kafka "transactions" topic.
#
# This uses raw kubernetes_deployment (not Helm) to demonstrate a
# production-grade K8s manifest managed via Terraform.
# =============================================================================

# --- Namespace ---
resource "kubernetes_namespace" "apps" {
  metadata {
    name = "apps"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "platform"                     = "fraud-detection"
      "tier"                         = "simulation"
    }
  }
}

# --- Kafka Credentials (mounted as secret) ---
resource "kubernetes_secret" "kafka_producer_credentials" {
  metadata {
    name      = "kafka-producer-credentials"
    namespace = kubernetes_namespace.apps.metadata[0].name
  }

  data = {
    KAFKA_SASL_PASSWORD = var.kafka_password
  }

  type = "Opaque"
}

# --- ConfigMap: Transaction Generator Script ---
resource "kubernetes_config_map" "transaction_generator_script" {
  metadata {
    name      = "transaction-generator-script"
    namespace = kubernetes_namespace.apps.metadata[0].name
  }

  data = {
    "generator.py" = <<-PYTHON
#!/usr/bin/env python3
"""
Transaction Generator — Fraud Detection Platform
Generates mock financial transactions and pushes them to Kafka.
"""
import json
import os
import random
import time
import uuid
from datetime import datetime, timezone

# --- Configuration from environment ---
KAFKA_BOOTSTRAP = os.environ["KAFKA_BOOTSTRAP_SERVERS"]
KAFKA_TOPIC     = os.environ.get("KAFKA_TOPIC", "transactions")
KAFKA_USER      = os.environ.get("KAFKA_SASL_USER", "fraud-platform")
KAFKA_PASSWORD  = os.environ["KAFKA_SASL_PASSWORD"]
RATE_MS         = int(os.environ.get("TRANSACTION_RATE_MS", "1000"))

# --- Mock data pools ---
CARD_PREFIXES   = ["4532", "5425", "6011", "3782"]
MERCHANTS       = [
    "Amazon.com", "Walmart", "Shell Gas", "Starbucks",
    "Netflix", "Uber", "Apple Store", "Best Buy",
    "Target", "Costco", "DoorDash", "Steam"
]
COUNTRIES       = ["US", "BR", "GB", "DE", "JP", "NG", "RU", "CN", "IN"]
CURRENCIES      = ["USD", "BRL", "GBP", "EUR", "JPY"]
MCC_CODES       = ["5411", "5541", "5812", "5912", "7011", "4121", "5732"]

def generate_transaction():
    """Generate a single mock transaction."""
    card_number = random.choice(CARD_PREFIXES) + "".join(
        [str(random.randint(0, 9)) for _ in range(12)]
    )
    is_suspicious = random.random() < 0.05  # 5% fraud rate

    amount = round(random.uniform(1.0, 500.0), 2)
    if is_suspicious:
        amount = round(random.uniform(2000.0, 50000.0), 2)

    return {
        "transaction_id": str(uuid.uuid4()),
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "card_number_hash": card_number[:4] + "****" + card_number[-4:],
        "amount": amount,
        "currency": random.choice(CURRENCIES),
        "merchant": random.choice(MERCHANTS),
        "mcc_code": random.choice(MCC_CODES),
        "country": random.choice(COUNTRIES),
        "ip_address": f"{random.randint(1,255)}.{random.randint(0,255)}.{random.randint(0,255)}.{random.randint(1,254)}",
        "device_fingerprint": str(uuid.uuid4())[:8],
        "is_international": random.choice([True, False]),
        "risk_score": round(random.uniform(0.8, 1.0), 3) if is_suspicious else round(random.uniform(0.0, 0.4), 3),
    }

def main():
    from kafka import KafkaProducer
    from kafka.errors import NoBrokersAvailable

    print(f"[TX-GEN] Connecting to Kafka at {KAFKA_BOOTSTRAP}...")

    # Retry loop for Kafka readiness
    producer = None
    for attempt in range(30):
        try:
            producer = KafkaProducer(
                bootstrap_servers=KAFKA_BOOTSTRAP.split(","),
                value_serializer=lambda v: json.dumps(v).encode("utf-8"),
                security_protocol="SASL_PLAINTEXT",
                sasl_mechanism="PLAIN",
                sasl_plain_username=KAFKA_USER,
                sasl_plain_password=KAFKA_PASSWORD,
            )
            print(f"[TX-GEN] Connected to Kafka on attempt {attempt + 1}")
            break
        except NoBrokersAvailable:
            print(f"[TX-GEN] Waiting for Kafka... (attempt {attempt + 1}/30)")
            time.sleep(10)

    if producer is None:
        print("[TX-GEN] FATAL: Could not connect to Kafka after 30 attempts")
        return

    print(f"[TX-GEN] Producing to topic '{KAFKA_TOPIC}' every {RATE_MS}ms")
    tx_count = 0
    while True:
        tx = generate_transaction()
        producer.send(KAFKA_TOPIC, value=tx)
        tx_count += 1
        if tx_count % 100 == 0:
            print(f"[TX-GEN] Sent {tx_count} transactions (latest: {tx['transaction_id'][:8]}... amount={tx['amount']} {tx['currency']})")
        time.sleep(RATE_MS / 1000.0)

if __name__ == "__main__":
    main()
    PYTHON
  }
}

# --- Deployment: Transaction Generator ---
resource "kubernetes_deployment" "transaction_generator" {
  metadata {
    name      = "transaction-generator"
    namespace = kubernetes_namespace.apps.metadata[0].name
    labels = {
      "app"                          = "transaction-generator"
      "app.kubernetes.io/name"       = "transaction-generator"
      "app.kubernetes.io/part-of"    = "fraud-detection-platform"
      "app.kubernetes.io/component"  = "simulator"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "transaction-generator"
      }
    }

    template {
      metadata {
        labels = {
          "app"                       = "transaction-generator"
          "app.kubernetes.io/name"    = "transaction-generator"
          "app.kubernetes.io/part-of" = "fraud-detection-platform"
        }
      }

      spec {
        # Init container: install kafka-python
        init_container {
          name  = "install-deps"
          image = var.transaction_generator_image

          command = ["/bin/sh", "-c"]
          args    = ["pip install --target=/app/deps kafka-python"]

          volume_mount {
            name       = "app-deps"
            mount_path = "/app/deps"
          }
        }

        # Main container
        container {
          name  = "generator"
          image = var.transaction_generator_image

          command = ["/bin/sh", "-c"]
          args    = ["export PYTHONPATH=/app/deps:$PYTHONPATH && python /app/generator.py"]

          # --- Environment Variables ---
          env {
            name  = "KAFKA_BOOTSTRAP_SERVERS"
            value = var.kafka_bootstrap_internal
          }

          env {
            name  = "KAFKA_TOPIC"
            value = "transactions"
          }

          env {
            name  = "KAFKA_SASL_USER"
            value = "fraud-platform"
          }

          env {
            name = "KAFKA_SASL_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.kafka_producer_credentials.metadata[0].name
                key  = "KAFKA_SASL_PASSWORD"
              }
            }
          }

          env {
            name  = "TRANSACTION_RATE_MS"
            value = var.transaction_rate_ms
          }

          # --- Resource Limits ---
          resources {
            limits = {
              memory = "256Mi"
              cpu    = "200m"
            }
            requests = {
              memory = "128Mi"
              cpu    = "50m"
            }
          }

          # --- Volume Mounts ---
          volume_mount {
            name       = "generator-script"
            mount_path = "/app/generator.py"
            sub_path   = "generator.py"
            read_only  = true
          }

          volume_mount {
            name       = "app-deps"
            mount_path = "/app/deps"
          }
        }

        # --- Volumes ---
        volume {
          name = "generator-script"
          config_map {
            name = kubernetes_config_map.transaction_generator_script.metadata[0].name
          }
        }

        volume {
          name = "app-deps"
          empty_dir {}
        }

        restart_policy = "Always"
      }
    }
  }
}
