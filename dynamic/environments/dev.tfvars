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

# Namespace configuration — just set the count
namespace_prefix          = "rtl"
namespace_count           = 2
namespace_cpu_requests    = "4"
namespace_memory_requests = "8Gi"
namespace_cpu_limits      = "8"
namespace_memory_limits   = "16Gi"