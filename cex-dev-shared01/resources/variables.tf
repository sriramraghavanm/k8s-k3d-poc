variable "cluster_context" {
  description = "Kubectl context name"
  type        = string
  default     = "cex-dev-shared01"
}

variable "namespaces" {
  description = "List of namespaces to create"
  type        = list(string)
  default     = ["rtl-dev01", "rtl-dev02"]
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