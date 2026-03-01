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

variable "namespace_prefix" {
  description = "Prefix for auto-generated namespace names (e.g. 'rtl' → rtl-dev01, rtl-dev02)"
  type        = string
  default     = "rtl"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.namespace_prefix))
    error_message = "Namespace prefix must start with a letter and contain only lowercase alphanumeric characters or hyphens."
  }
}

variable "namespace_count" {
  description = "Number of namespaces to create for this environment"
  type        = number
  default     = 2

  validation {
    condition     = var.namespace_count >= 1 && var.namespace_count <= 99
    error_message = "Namespace count must be between 1 and 99."
  }
}

variable "namespace_cpu_requests" {
  description = "Total CPU requests quota per namespace"
  type        = string
  default     = "4"
}

variable "namespace_memory_requests" {
  description = "Total memory requests quota per namespace"
  type        = string
  default     = "8Gi"
}

variable "namespace_cpu_limits" {
  description = "Total CPU limits quota per namespace"
  type        = string
  default     = "8"
}

variable "namespace_memory_limits" {
  description = "Total memory limits quota per namespace"
  type        = string
  default     = "16Gi"
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

# ---------------------------------------------------------------------------
# Sink variables — declared so the shared -var-file does not produce
# "undeclared variable" errors. These are unused in the resources module.
# ---------------------------------------------------------------------------

variable "server_count" {
  description = "Unused in resources module — declared to accept shared var-file"
  type        = number
  default     = 0
}

variable "agent_count" {
  description = "Unused in resources module — declared to accept shared var-file"
  type        = number
  default     = 0
}

variable "api_port" {
  description = "Unused in resources module — declared to accept shared var-file"
  type        = number
  default     = 0
}

variable "lb_http_port" {
  description = "Unused in resources module — declared to accept shared var-file"
  type        = number
  default     = 0
}

variable "lb_https_port" {
  description = "Unused in resources module — declared to accept shared var-file"
  type        = number
  default     = 0
}

variable "enable_registry" {
  description = "Unused in resources module — declared to accept shared var-file"
  type        = bool
  default     = false
}

variable "registry_port" {
  description = "Unused in resources module — declared to accept shared var-file"
  type        = number
  default     = 0
}

variable "persistent_volume_path" {
  description = "Unused in resources module — declared to accept shared var-file"
  type        = string
  default     = ""
}