# Real-Time Fraud Detection Platform

> **Corporate-grade local simulation** — Kubernetes (Kind) + Terraform IaC for a high-throughput fraud detection pipeline.

```
  ┌──────────────────────────────────────────────────────────┐
  │                   Kind Kubernetes Cluster                │
  │                                                          │
  │  ┌──────────┐   ┌──────────┐   ┌──────────────────────┐ │
  │  │  Kafka    │◄──│ TX Gen   │   │  Spark               │ │
  │  │  (3 brkr) │   │ (Python) │   │  (1 master + 2 wrkr) │ │
  │  └────┬─────┘   └──────────┘   └──────┬───────────────┘ │
  │       │                                │                  │
  │  ┌────▼─────┐                    ┌─────▼────┐            │
  │  │ Kafka UI │                    │ Cassandra│            │
  │  └──────────┘                    │ Redis    │            │
  │                                  └──────────┘            │
  └──────────────────────────────────────────────────────────┘
```

## Tech Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Event Bus** | Apache Kafka (Bitnami, KRaft) | High-throughput transaction ingestion |
| **Observability** | Kafka UI (Provectus) | Real-time topic & consumer monitoring |
| **Hot Storage** | Redis (Sentinel HA) | Temporary fraud rules, card blocks |
| **Historical Storage** | Apache Cassandra | Transaction history, pattern analysis |
| **Processing** | Apache Spark | Structured Streaming from Kafka |
| **Simulation** | Transaction Generator (Python) | Mock financial transaction producer |

## Prerequisites

| Tool | Minimum Version | Install |
|------|----------------|---------|
| Docker Desktop | 24.x | [docker.com](https://docs.docker.com/desktop/) |
| Kind | 0.20+ | `choco install kind` / `brew install kind` |
| Terraform | 1.5+ | `choco install terraform` / `brew install terraform` |
| kubectl | 1.28+ | `choco install kubernetes-cli` / `brew install kubectl` |

> [!IMPORTANT]
> Ensure Docker Desktop is configured with at least **16 GB RAM** and **6+ CPUs**. This stack runs ~15 containers.

## Quick Start

### 1. Set Credentials

```powershell
# PowerShell
$env:TF_VAR_kafka_password = "your-secure-kafka-password"
$env:TF_VAR_redis_password = "your-secure-redis-password"
$env:TF_VAR_cassandra_password = "your-secure-cassandra-password"
```

```bash
# Bash / Zsh
export TF_VAR_kafka_password="your-secure-kafka-password"
export TF_VAR_redis_password="your-secure-redis-password"
export TF_VAR_cassandra_password="your-secure-cassandra-password"
```

### 2. Deploy

```bash
# Initialize Terraform (downloads providers ~2 min)
terraform init

# Review the execution plan
terraform plan

# Apply (provisions cluster + all services ~10-15 min)
terraform apply
```

### 3. Verify

```bash
# Check cluster nodes
kubectl get nodes

# Check all pods
kubectl get pods --all-namespaces

# Watch transaction generator logs
kubectl logs -n apps -l app=transaction-generator -f
```

## Port Allocation

| Service | NodePort | Access |
|---------|----------|--------|
| Kafka External (Broker 0) | `30092` | `localhost:30092` |
| Kafka External (Broker 1) | `30093` | `localhost:30093` |
| Kafka External (Broker 2) | `30094` | `localhost:30094` |
| Kafka UI | `30989` | [http://localhost:30989](http://localhost:30989) |
| Redis Master | `30379` | `localhost:30379` |
| Cassandra CQL | `30942` | `localhost:30942` |
| Spark Master UI | `30808` | [http://localhost:30808](http://localhost:30808) |

## Project Structure

```
.
├── main.tf                          # Root orchestration (module calls)
├── providers.tf                     # Terraform + provider configuration
├── variables.tf                     # Global input variables
├── outputs.tf                       # Access URLs and credentials
├── terraform.tfvars                 # Default non-sensitive values
├── kind-config.yaml                 # Kind cluster topology
├── .github/workflows/
│   └── infra-check.yaml             # CI: fmt → validate → plan
└── modules/
    ├── cluster/                     # Kind cluster provisioning
    ├── streaming/                   # Kafka (KRaft) + Kafka UI
    ├── hot-storage/                 # Redis (Sentinel mode)
    ├── databases/                   # Cassandra (wide-column)
    ├── processing/                  # Spark (master + workers)
    └── app-simulator/               # Transaction Generator (Python)
```

## Secrets Management

Credentials are **never hardcoded**. They flow as:

```
TF_VAR_* env vars → Terraform variables (sensitive) → kubernetes_secret resources → Pod env vars
```

For CI/CD, configure GitHub Secrets:
- `KAFKA_PASSWORD`
- `REDIS_PASSWORD`
- `CASSANDRA_PASSWORD`

## Resource Limits

| Component | Memory Limit | CPU Limit | Notes |
|-----------|-------------|-----------|-------|
| Kafka (per broker) | 1536Mi | 1000m | 3 brokers × 1.5GB |
| Cassandra | 3Gi | 2000m | JVM heap capped at 2GB |
| Redis (per replica) | 512Mi | 500m | 1 master + 2 replicas |
| Spark Master | 512Mi | 500m | Web UI + coordination |
| Spark Worker | 1Gi | 1000m | 2 workers × 1GB |
| TX Generator | 256Mi | 200m | Lightweight Python |

**Estimated total:** ~12 GB RAM

## Useful Commands

```bash
# Connect to Cassandra via cqlsh
kubectl exec -it -n databases cassandra-0 -- cqlsh -u cassandra -p $TF_VAR_cassandra_password

# Connect to Redis
kubectl exec -it -n hot-storage redis-master-0 -- redis-cli -a $TF_VAR_redis_password

# Submit a Spark job
kubectl exec -it -n processing spark-master-0 -- spark-submit --master spark://spark-master-svc:7077 your_job.py

# Scale transaction generator
kubectl scale deployment -n apps transaction-generator --replicas=3
```

## Teardown

```bash
# Destroy all infrastructure
terraform destroy

# (Optional) Delete Kind cluster manually
kind delete cluster --name fraud-detection-platform
```

## CI/CD Pipeline

The `.github/workflows/infra-check.yaml` runs on every PR:

1. `terraform fmt -check -recursive` — formatting compliance
2. `terraform init -backend=false` — provider resolution
3. `terraform validate` — configuration validity
4. `terraform plan` — resource graph verification

Results are automatically posted as PR comments.

## Architecture Decisions

| Decision | Rationale |
|----------|-----------|
| **KRaft** (no Zookeeper) | Simplified topology, fewer containers, modern Kafka standard |
| **Redis Sentinel** (not Cluster) | HA without needing 6+ nodes locally |
| **Cassandra single-node** | Sufficient for simulation; heap-capped to prevent OOM |
| **Raw K8s Deployment** for TX Gen | Demonstrates Terraform K8s provider; easy to customize |
| **Bitnami charts** | Consistent, well-maintained, production-grade defaults |

---

**License:** Internal / Educational Use
