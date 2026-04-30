terraform {
  required_version = ">= 1.0"
}

# 🚨 Kubernetes pod running as root (very commonly flagged)
resource "kubernetes_pod" "bad" {
  metadata {
    name = "insecure-pod"
  }

  spec {
    container {
      name  = "nginx"
      image = "nginx"

      security_context {
        run_as_user = 0
      }
    }
  }
}
