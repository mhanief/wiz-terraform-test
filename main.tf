terraform {
  required_version = ">= 1.0"
}

# Pod 1: HostAliases issue (keep 1 only)
resource "kubernetes_pod" "host_alias_issue" {
  metadata {
    name = "pod-host-alias"
  }

  spec {
    container {
      name  = "nginx"
      image = "nginx"
    }
  }
}

# Pod 2: Run as root + privileged
resource "kubernetes_pod" "privileged_pod" {
  metadata {
    name = "pod-privileged"
  }

  spec {
    container {
      name  = "nginx"
      image = "nginx:latest"

      security_context {
        run_as_user                = 0
        privileged                 = true
        allow_privilege_escalation = true
      }
    }
  }
}

# Pod 3: Host network access
resource "kubernetes_pod" "host_network" {
  metadata {
    name = "pod-host-network"
  }

  spec {
    host_network = true

    container {
      name  = "nginx"
      image = "nginx"
    }
  }
}

# Pod 4: Missing resource limits
resource "kubernetes_pod" "no_limits" {
  metadata {
    name = "pod-no-limits"
  }

  spec {
    container {
      name  = "nginx"
      image = "nginx"
      # no resources block
    }
  }
}

# Pod 5: Insecure image tag
resource "kubernetes_pod" "latest_tag" {
  metadata {
    name = "pod-latest-tag"
  }

  spec {
    container {
      name  = "nginx"
      image = "nginx:latest"
    }
  }
}
