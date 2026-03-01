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

namespace_prefix          = "rtl"
namespace_count           = 3
namespace_cpu_requests    = "4"
namespace_memory_requests = "8Gi"
namespace_cpu_limits      = "8"
namespace_memory_limits   = "16Gi"