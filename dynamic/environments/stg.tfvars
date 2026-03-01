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

namespace_prefix          = "rtl"
namespace_count           = 2
namespace_cpu_requests    = "8"
namespace_memory_requests = "16Gi"
namespace_cpu_limits      = "16"
namespace_memory_limits   = "32Gi"