locals {
  cluster_name    = "cex-${var.environment}-${var.cluster_suffix}"
  cluster_context = "k3d-${local.cluster_name}"

  # Dynamically generate namespace names: rtl-dev01, rtl-dev02, ... rtl-devNN
  namespace_names = [
    for i in range(1, var.namespace_count + 1) :
    "${var.namespace_prefix}-${var.environment}${format("%02d", i)}"
  ]

  # Build a map keyed by namespace name for use in for_each
  namespace_map = { for name in local.namespace_names : name => {
    cpu_requests    = var.namespace_cpu_requests
    memory_requests = var.namespace_memory_requests
    cpu_limits      = var.namespace_cpu_limits
    memory_limits   = var.namespace_memory_limits
  } }

  common_labels = {
    "managed-by"  = "terraform"
    "environment" = var.environment
    "cluster"     = local.cluster_name
  }

  # Environment-specific tuning for limit ranges and Helm resource defaults
  env_config = {
    dev = {
      pod_security_level = "restricted"
      max_pod_cpu        = "4"
      max_pod_memory     = "8Gi"
      max_container_cpu  = "2"
      max_container_memory = "4Gi"
      default_cpu        = "500m"
      default_memory     = "512Mi"
      default_req_cpu    = "100m"
      default_req_memory = "128Mi"
    }
    qa = {
      pod_security_level = "restricted"
      max_pod_cpu        = "4"
      max_pod_memory     = "8Gi"
      max_container_cpu  = "2"
      max_container_memory = "4Gi"
      default_cpu        = "500m"
      default_memory     = "512Mi"
      default_req_cpu    = "100m"
      default_req_memory = "128Mi"
    }
    stg = {
      pod_security_level = "restricted"
      max_pod_cpu        = "8"
      max_pod_memory     = "16Gi"
      max_container_cpu  = "4"
      max_container_memory = "8Gi"
      default_cpu        = "500m"
      default_memory     = "512Mi"
      default_req_cpu    = "200m"
      default_req_memory = "256Mi"
    }
    prod = {
      pod_security_level = "restricted"
      max_pod_cpu        = "16"
      max_pod_memory     = "32Gi"
      max_container_cpu  = "8"
      max_container_memory = "16Gi"
      default_cpu        = "1"
      default_memory     = "1Gi"
      default_req_cpu    = "250m"
      default_req_memory = "256Mi"
    }
  }

  env = local.env_config[var.environment]
}

# ---------------------------------------------------------------------------
# Providers
# ---------------------------------------------------------------------------
provider "kubernetes" {
  config_path    = pathexpand("~/.kube/config")
  config_context = local.cluster_context
}

provider "helm" {
  kubernetes {
    config_path    = pathexpand("~/.kube/config")
    config_context = local.cluster_context
  }
}

# ---------------------------------------------------------------------------
# Namespaces
# ---------------------------------------------------------------------------
resource "kubernetes_namespace" "namespaces" {
  for_each = local.namespace_map

  metadata {
    name = each.key

    labels = merge(local.common_labels, {
      "name"                               = each.key
      "pod-security.kubernetes.io/enforce" = local.env.pod_security_level
      "pod-security.kubernetes.io/audit"   = local.env.pod_security_level
      "pod-security.kubernetes.io/warn"    = local.env.pod_security_level
    })

    annotations = {
      "description" = "Namespace ${each.key} for CEX ${upper(var.environment)} environment"
      "created-by"  = "terraform"
      "team"        = "rtl-team"
    }
  }
}

# ---------------------------------------------------------------------------
# Resource Quotas (per-namespace values from variables)
# ---------------------------------------------------------------------------
resource "kubernetes_resource_quota" "namespace_quotas" {
  for_each   = local.namespace_map
  depends_on = [kubernetes_namespace.namespaces]

  metadata {
    name      = "${each.key}-quota"
    namespace = each.key
    labels    = local.common_labels
  }

  spec {
    hard = {
      "requests.cpu"           = each.value.cpu_requests
      "requests.memory"        = each.value.memory_requests
      "limits.cpu"             = each.value.cpu_limits
      "limits.memory"          = each.value.memory_limits
      "persistentvolumeclaims" = "10"
      "pods"                   = "50"
      "services"               = "20"
      "services.loadbalancers" = "5"
      "services.nodeports"     = "5"
      "configmaps"             = "50"
      "secrets"                = "50"
    }
  }
}

# ---------------------------------------------------------------------------
# Limit Ranges (environment-aware defaults)
# ---------------------------------------------------------------------------
resource "kubernetes_limit_range" "namespace_limits" {
  for_each   = local.namespace_map
  depends_on = [kubernetes_namespace.namespaces]

  metadata {
    name      = "${each.key}-limits"
    namespace = each.key
    labels    = local.common_labels
  }

  spec {
    limit {
      type = "Pod"
      max = {
        cpu    = local.env.max_pod_cpu
        memory = local.env.max_pod_memory
      }
      min = {
        cpu    = "10m"
        memory = "10Mi"
      }
    }

    limit {
      type = "Container"
      default = {
        cpu    = local.env.default_cpu
        memory = local.env.default_memory
      }
      default_request = {
        cpu    = local.env.default_req_cpu
        memory = local.env.default_req_memory
      }
      max = {
        cpu    = local.env.max_container_cpu
        memory = local.env.max_container_memory
      }
      min = {
        cpu    = "10m"
        memory = "10Mi"
      }
    }
  }
}

# ---------------------------------------------------------------------------
# Network Policies — Default Deny + Allow DNS
# ---------------------------------------------------------------------------
resource "kubernetes_network_policy" "default_deny_ingress" {
  for_each   = local.namespace_map
  depends_on = [kubernetes_namespace.namespaces]

  metadata {
    name      = "default-deny-ingress"
    namespace = each.key
    labels    = local.common_labels
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "default_deny_egress" {
  for_each   = local.namespace_map
  depends_on = [kubernetes_namespace.namespaces]

  metadata {
    name      = "default-deny-egress"
    namespace = each.key
    labels    = local.common_labels
  }

  spec {
    pod_selector {}
    policy_types = ["Egress"]
  }
}

resource "kubernetes_network_policy" "allow_dns" {
  for_each   = local.namespace_map
  depends_on = [kubernetes_namespace.namespaces]

  metadata {
    name      = "allow-dns"
    namespace = each.key
    labels    = local.common_labels
  }

  spec {
    pod_selector {}
    policy_types = ["Egress"]

    egress {
      to {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = "kube-system"
          }
        }
      }

      ports {
        protocol = "UDP"
        port     = "53"
      }
      ports {
        protocol = "TCP"
        port     = "53"
      }
    }
  }
}

# ---------------------------------------------------------------------------
# Service Accounts & RBAC
# ---------------------------------------------------------------------------
resource "kubernetes_service_account" "namespace_sa" {
  for_each   = local.namespace_map
  depends_on = [kubernetes_namespace.namespaces]

  metadata {
    name      = "${each.key}-sa"
    namespace = each.key
    labels    = local.common_labels
    annotations = {
      "description" = "Service account for ${each.key} namespace"
    }
  }
}

resource "kubernetes_role" "namespace_admin" {
  for_each   = local.namespace_map
  depends_on = [kubernetes_namespace.namespaces]

  metadata {
    name      = "${each.key}-admin"
    namespace = each.key
    labels    = local.common_labels
  }

  rule {
    api_groups = ["", "apps", "batch", "extensions"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["networkpolicies", "ingresses"]
    verbs      = ["*"]
  }
}

# ---------------------------------------------------------------------------
# Helm Charts — NGINX Ingress & cert-manager
# ---------------------------------------------------------------------------
resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  version          = var.ingress_nginx_version
  create_namespace = true

  values = [yamlencode({
    controller = {
      service = {
        type = "NodePort"
      }
      metrics = {
        enabled = true
      }
      resources = {
        requests = {
          cpu    = local.env.default_req_cpu
          memory = local.env.default_req_memory
        }
        limits = {
          cpu    = local.env.default_cpu
          memory = local.env.default_memory
        }
      }
    }
  })]
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  version          = var.cert_manager_version
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }
}

# ---------------------------------------------------------------------------
# Priority Classes
# ---------------------------------------------------------------------------
resource "kubernetes_priority_class" "high_priority" {
  metadata {
    name   = "high-priority"
    labels = local.common_labels
  }
  value          = 1000
  global_default = false
  description    = "High priority class for critical workloads"
}

resource "kubernetes_priority_class" "medium_priority" {
  metadata {
    name   = "medium-priority"
    labels = local.common_labels
  }
  value          = 500
  global_default = true
  description    = "Medium priority class for standard workloads"
}

resource "kubernetes_priority_class" "low_priority" {
  metadata {
    name   = "low-priority"
    labels = local.common_labels
  }
  value          = 100
  global_default = false
  description    = "Low priority class for non-critical workloads"
}