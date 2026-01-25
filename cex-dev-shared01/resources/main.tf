locals {
  common_labels = {
    "managed-by"  = "terraform"
    "environment" = "development"
    "cluster"     = "k3d-${var.cluster_context}"
  }
}

# Kubernetes provider configuration
provider "kubernetes" {
  config_path    = pathexpand("~/.kube/config")
  config_context = "k3d-${var.cluster_context}"
}

provider "helm" {
  kubernetes {
    config_path    = pathexpand("~/.kube/config")
    config_context = "k3d-${var.cluster_context}"
  }
}

# Create namespaces with production best practices
resource "kubernetes_namespace" "namespaces" {
  for_each = toset(var.namespaces)

  metadata {
    name = each.value
    
    labels = merge(local.common_labels, {
      "name"                                   = each.value
      "pod-security.kubernetes.io/enforce"     = "restricted"
      "pod-security.kubernetes.io/audit"       = "restricted"
      "pod-security.kubernetes.io/warn"        = "restricted"
    })
    
    annotations = {
      "description" = "Namespace ${each.value} for CEX development environment"
      "created-by"  = "terraform"
      "team"        = "rtl-team"
    }
  }
}

# Resource Quotas for each namespace
resource "kubernetes_resource_quota" "namespace_quotas" {
  for_each = toset(var.namespaces)
  
  depends_on = [kubernetes_namespace. namespaces]

  metadata {
    name      = "${each.value}-quota"
    namespace = each.value
    labels    = local.common_labels
  }

  spec {
    hard = {
      "requests.cpu"               = var.namespace_cpu_requests
      "requests.memory"            = var.namespace_memory_requests
      "limits.cpu"                 = var.namespace_cpu_limits
      "limits.memory"              = var.namespace_memory_limits
      "persistentvolumeclaims"     = "10"
      "pods"                       = "50"
      "services"                   = "20"
      "services.loadbalancers"     = "5"
      "services.nodeports"         = "5"
      "configmaps"                 = "50"
      "secrets"                    = "50"
    }
  }
}

# Limit Ranges for each namespace
resource "kubernetes_limit_range" "namespace_limits" {
  for_each = toset(var.namespaces)
  
  depends_on = [kubernetes_namespace. namespaces]

  metadata {
    name      = "${each. value}-limits"
    namespace = each.value
    labels    = local.common_labels
  }

  spec {
    limit {
      type = "Pod"
      max = {
        cpu    = "4"
        memory = "8Gi"
      }
      min = {
        cpu    = "10m"
        memory = "10Mi"
      }
    }
    
    limit {
      type = "Container"
      default = {
        cpu    = "500m"
        memory = "512Mi"
      }
      default_request = {
        cpu    = "100m"
        memory = "128Mi"
      }
      max = {
        cpu    = "2"
        memory = "4Gi"
      }
      min = {
        cpu    = "10m"
        memory = "10Mi"
      }
    }
  }
}

# Network Policies - Default Deny All
resource "kubernetes_network_policy" "default_deny_ingress" {
  for_each = toset(var.namespaces)
  
  depends_on = [kubernetes_namespace.namespaces]

  metadata {
    name      = "default-deny-ingress"
    namespace = each.value
    labels    = local.common_labels
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "default_deny_egress" {
  for_each = toset(var.namespaces)
  
  depends_on = [kubernetes_namespace.namespaces]

  metadata {
    name      = "default-deny-egress"
    namespace = each.value
    labels    = local.common_labels
  }

  spec {
    pod_selector {}
    policy_types = ["Egress"]
  }
}

# Allow DNS traffic
resource "kubernetes_network_policy" "allow_dns" {
  for_each = toset(var.namespaces)
  
  depends_on = [kubernetes_namespace. namespaces]

  metadata {
    name      = "allow-dns"
    namespace = each. value
    labels    = local. common_labels
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

# Service Accounts
resource "kubernetes_service_account" "namespace_sa" {
  for_each = toset(var.namespaces)
  
  depends_on = [kubernetes_namespace. namespaces]

  metadata {
    name      = "${each.value}-sa"
    namespace = each.value
    labels    = local.common_labels
    annotations = {
      "description" = "Service account for ${each.value} namespace"
    }
  }
}

# RBAC Roles
resource "kubernetes_role" "namespace_admin" {
  for_each = toset(var.namespaces)
  
  depends_on = [kubernetes_namespace.namespaces]

  metadata {
    name      = "${each.value}-admin"
    namespace = each. value
    labels    = local. common_labels
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

# Install NGINX Ingress Controller
resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  version          = "4.8.3"
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
          cpu    = "100m"
          memory = "128Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "512Mi"
        }
      }
    }
  })]
}

# Install cert-manager
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  version          = "v1.13.3"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }
}

# Priority Classes
resource "kubernetes_priority_class" "high_priority" {
  metadata {
    name = "high-priority"
  }
  value          = 1000
  global_default = false
  description    = "High priority class for critical workloads"
}

resource "kubernetes_priority_class" "medium_priority" {
  metadata {
    name = "medium-priority"
  }
  value          = 500
  global_default = true
  description    = "Medium priority class for standard workloads"
}

resource "kubernetes_priority_class" "low_priority" {
  metadata {
    name = "low-priority"
  }
  value          = 100
  global_default = false
  description    = "Low priority class for non-critical workloads"
}