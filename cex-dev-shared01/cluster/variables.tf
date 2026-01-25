variable "cluster_name" {
  description = "Name of the k3d cluster"
  type        = string
  default     = "cex-dev-shared01"
}

variable "server_count" {
  description = "Number of server nodes (control plane)"
  type        = number
  default     = 3
}

variable "agent_count" {
  description = "Number of agent nodes (workers)"
  type        = number
  default     = 3
}

variable "api_port" {
  description = "API server port"
  type        = number
  default     = 6443
}

variable "lb_http_port" {
  description = "Load balancer HTTP port"
  type        = number
  default     = 8081
}

variable "lb_https_port" {
  description = "Load balancer HTTPS port"
  type        = number
  default     = 8443
}

variable "enable_registry" {
  description = "Enable local container registry"
  type        = bool
  default     = true
}

variable "registry_port" {
  description = "Local registry port"
  type        = number
  default     = 5010
}

variable "persistent_volume_path" {
  description = "Host path for persistent volumes"
  type        = string
  default     = "/tmp/k3d-cex-dev-shared01-storage"
}
