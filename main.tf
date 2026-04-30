terraform {
  required_version = ">= 1.0"
}

# Pod 1: running as root + missing security best practices
resource "kubernetes_pod" "bad_root" {
  metadata {
    name = "insecure-pod-root"
    labels = {
      env = "test"
    }
  }

  spec {
    container {
      name  = "nginx"
      image = "nginx:latest" # latest tag (bad practice)

      security_context {
        run_as_user = 0               # running as root
        privileged  = true            # privileged container
        allow_privilege_escalation = true # escalation allowed
      }
    }
  }
}

# Pod 2: missing resource limits + insecure image
resource "kubernetes_pod" "bad_resources" {
  metadata {
    name = "no-limits-pod"
  }

  spec {
    container {
      name  = "app"
      image = "nginx" # no version pinning

      # no resources block (CPU/memory limits missing)
    }
  }
}

# Pod 3: dangerous host settings
resource "kubernetes_pod" "bad_host" {
  metadata {
    name = "host-access-pod"
  }

  spec {
    host_network = true  # access to host network

    container {
      name  = "app"
      image = "nginx"

      security_context {
        run_as_user = 0
      }
    }
  }
}

# Pod 4: missing security context entirely
resource "kubernetes_pod" "no_security" {
  metadata {
    name = "no-security-context"
  }

  spec {
    container {
      name  = "app"
      image = "nginx"
    }
  }
}
