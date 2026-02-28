# Production Environment
environment        = "prod"
cluster_suffix     = "shared01"
server_count       = 5
agent_count        = 7
api_port           = 6446
lb_http_port       = 8084
lb_https_port      = 8446
enable_registry    = true
registry_port      = 5013

namespaces = [
  { name = "rtl-prod01", cpu_requests = "16", memory_requests = "32Gi", cpu_limits = "32", memory_limits = "64Gi" },
  { name = "rtl-prod02", cpu_requests = "16", memory_requests = "32Gi", cpu_limits = "32", memory_limits = "64Gi" },
  { name = "rtl-prod03", cpu_requests = "16", memory_requests = "32Gi", cpu_limits = "32", memory_limits = "64Gi" },
  { name = "rtl-prod04", cpu_requests = "16", memory_requests = "32Gi", cpu_limits = "32", memory_limits = "64Gi" },
]