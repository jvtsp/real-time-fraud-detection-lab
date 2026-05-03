# =============================================================================
# Real-Time Fraud Detection Platform — Provider Configuration
# =============================================================================
# Providers: Kind (cluster), Kubernetes (resources), Helm (charts)
# =============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.6"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
  }

  # Local backend — structured for easy migration to S3/GCS
  backend "local" {
    path = "terraform.tfstate"
  }
}

# -----------------------------------------------------------------------------
# Kind Provider — manages the Kind cluster lifecycle
# -----------------------------------------------------------------------------
provider "kind" {}

# -----------------------------------------------------------------------------
# Kubernetes Provider — configured from Kind cluster output
# -----------------------------------------------------------------------------
provider "kubernetes" {
  host                   = module.cluster.endpoint
  cluster_ca_certificate = module.cluster.cluster_ca_certificate
  client_certificate     = module.cluster.client_certificate
  client_key             = module.cluster.client_key
}

# -----------------------------------------------------------------------------
# Helm Provider — configured from Kind cluster output
# -----------------------------------------------------------------------------
provider "helm" {
  kubernetes {
    host                   = module.cluster.endpoint
    cluster_ca_certificate = module.cluster.cluster_ca_certificate
    client_certificate     = module.cluster.client_certificate
    client_key             = module.cluster.client_key
  }
}
