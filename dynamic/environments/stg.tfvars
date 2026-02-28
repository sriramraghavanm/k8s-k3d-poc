# Staging Environment
environment        = "stg"
cluster_suffix     = "shared01"
server_count       = 3
agent_count        = 5
api_port           = 6445
lb_http_port       = 8083
lb_https_port      = 8445
enable_registry    = true
registry_port      = 5012

namespaces = [
  { name = "rtl-stg01", cpu_requests = "8",  memory_requests = "16Gi", cpu_limits = "16", memory_limits = "32Gi" },
  { name = "rtl-stg02", cpu_requests = "8",  memory_requests = "16Gi", cpu_limits = "16", memory_limits = "32Gi" },
]