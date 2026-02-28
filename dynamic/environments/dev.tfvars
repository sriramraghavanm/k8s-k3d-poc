# Development Environment
environment        = "dev"
cluster_suffix     = "shared01"
server_count       = 3
agent_count        = 3
api_port           = 6443
lb_http_port       = 8081
lb_https_port      = 8443
enable_registry    = true
registry_port      = 5010

namespaces = [
  { name = "rtl-dev01", cpu_requests = "4", memory_requests = "8Gi", cpu_limits = "8", memory_limits = "16Gi" },
  { name = "rtl-dev02", cpu_requests = "4", memory_requests = "8Gi", cpu_limits = "8", memory_limits = "16Gi" },
]