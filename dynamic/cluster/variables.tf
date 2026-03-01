variable "environment" {
  description = "Environment name (dev, qa, stg, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "stg", "prod"], var.environment)
    error_message = "Environment must be one of: dev, qa, stg, prod."
  }
}

variable "cluster_suffix" {
  description = "Suffix appended to the cluster name (e.g. shared01)"
  type        = string
  default     = "shared01"

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.cluster_suffix))
    error_message = "Cluster suffix must contain only lowercase alphanumeric characters."
  }
}

variable "server_count" {
  description = "Number of server (control-plane) nodes"
  type        = number
  default     = 3

  validation {
    condition     = var.server_count >= 1 && var.server_count % 2 == 1
    error_message = "Server count must be an odd number >= 1 for proper etcd quorum."
  }
}

variable "agent_count" {
  description = "Number of agent (worker) nodes"
  type        = number
  default     = 3

  validation {
    condition     = var.agent_count >= 1
    error_message = "Agent count must be at least 1."
  }
}

variable "api_port" {
  description = "Kubernetes API server port"
  type        = number
  default     = 6443

  validation {
    condition     = var.api_port >= 1024 && var.api_port <= 65535
    error_message = "API port must be between 1024 and 65535."
  }
}

variable "lb_http_port" {
  description = "Load balancer HTTP port"
  type        = number
  default     = 8081

  validation {
    condition     = var.lb_http_port >= 1024 && var.lb_http_port <= 65535
    error_message = "HTTP port must be between 1024 and 65535."
  }
}

variable "lb_https_port" {
  description = "Load balancer HTTPS port"
  type        = number
  default     = 8443

  validation {
    condition     = var.lb_https_port >= 1024 && var.lb_https_port <= 65535
    error_message = "HTTPS port must be between 1024 and 65535."
  }
}

variable "enable_registry" {
  description = "Enable a local container registry alongside the cluster"
  type        = bool
  default     = true
}

variable "registry_port" {
  description = "Port for the local container registry"
  type        = number
  default     = 5010

  validation {
    condition     = var.registry_port >= 1024 && var.registry_port <= 65535
    error_message = "Registry port must be between 1024 and 65535."
  }
}

variable "persistent_volume_path" {
  description = "Override for the host path used for persistent volumes. Leave empty to auto-generate."
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# Sink variables — declared so the shared -var-file does not produce
# "undeclared variable" errors. These are unused in the cluster module.
# ---------------------------------------------------------------------------

variable "namespace_prefix" {
  description = "Unused in cluster module — declared to accept shared var-file"
  type        = string
  default     = ""
}

variable "namespace_count" {
  description = "Unused in cluster module — declared to accept shared var-file"
  type        = number
  default     = 0
}

variable "namespace_cpu_requests" {
  description = "Unused in cluster module — declared to accept shared var-file"
  type        = string
  default     = ""
}

variable "namespace_memory_requests" {
  description = "Unused in cluster module — declared to accept shared var-file"
  type        = string
  default     = ""
}

variable "namespace_cpu_limits" {
  description = "Unused in cluster module — declared to accept shared var-file"
  type        = string
  default     = ""
}

variable "namespace_memory_limits" {
  description = "Unused in cluster module — declared to accept shared var-file"
  type        = string
  default     = ""
}

variable "ingress_nginx_version" {
  description = "Unused in cluster module — declared to accept shared var-file"
  type        = string
  default     = ""
}

variable "cert_manager_version" {
  description = "Unused in cluster module — declared to accept shared var-file"
  type        = string
  default     = ""
}