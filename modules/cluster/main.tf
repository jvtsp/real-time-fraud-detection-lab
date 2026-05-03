# =============================================================================
# Module: cluster — Kind Kubernetes Cluster
# =============================================================================

terraform {
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.6"
    }
  }
}

resource "kind_cluster" "this" {
  name           = var.cluster_name
  node_image     = "kindest/node:${var.kubernetes_version}"
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    # --- Control Plane ---
    node {
      role = "control-plane"

      kubeadm_config_patches = [
        <<-EOT
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
        EOT
      ]

      # NodePort mappings for all platform services
      dynamic "extra_port_mappings" {
        for_each = var.nodeport_mappings
        content {
          container_port = extra_port_mappings.value
          host_port      = extra_port_mappings.value
          protocol       = "TCP"
        }
      }
    }

    # --- Worker Nodes ---
    node {
      role = "worker"
    }

    node {
      role = "worker"
    }
  }
}
