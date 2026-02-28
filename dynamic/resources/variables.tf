variable "environment" {
  description = "Environment name (dev, qa, stg, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "stg", "prod"], var.environment)
    error_message = "Environment must be one of: dev, qa, stg, prod."
  }
}

variable "cluster_suffix" {
  description = "Suffix appended to the cluster name"
  type        = string
  default     = "shared01"
}

variable "namespaces" {
  description = "List of namespace definitions with per-namespace resource quotas"
  type = list(object({
    name            = string
    cpu_requests    = string
    memory_requests = string
    cpu_limits      = string
    memory_limits   = string
  }))

  validation {
    condition     = length(var.namespaces) > 0
    error_message = "At least one namespace must be defined."
  }

  validation {
    condition     = length(var.namespaces) == length(distinct([for ns in var.namespaces : ns.name]))
    error_message = "Namespace names must be unique."
  }
}

variable "ingress_nginx_version" {
  description = "Version of the ingress-nginx Helm chart"
  type        = string
  default     = "4.8.3"
}

variable "cert_manager_version" {
  description = "Version of the cert-manager Helm chart"
  type        = string
  default     = "v1.13.3"
}