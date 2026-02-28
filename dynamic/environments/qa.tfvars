# QA Environment
environment        = "qa"
cluster_suffix     = "shared01"
server_count       = 3
agent_count        = 3
api_port           = 6444
lb_http_port       = 8082
lb_https_port      = 8444
enable_registry    = true
registry_port      = 5011

namespaces = [
  { name = "rtl-qa01", cpu_requests = "4",  memory_requests = "8Gi",  cpu_limits = "8",  memory_limits = "16Gi" },
  { name = "rtl-qa02", cpu_requests = "4",  memory_requests = "8Gi",  cpu_limits = "8",  memory_limits = "16Gi" },
  { name = "rtl-qa03", cpu_requests = "4",  memory_requests = "8Gi",  cpu_limits = "8",  memory_limits = "16Gi" },
]