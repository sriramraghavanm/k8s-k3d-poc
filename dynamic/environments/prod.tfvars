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

namespace_prefix          = "rtl"
namespace_count           = 2
namespace_cpu_requests    = "16"
namespace_memory_requests = "32Gi"
namespace_cpu_limits      = "32"
namespace_memory_limits   = "64Gi"