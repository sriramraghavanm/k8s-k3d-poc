output "cluster_name" {
  description = "Name of the created k3d cluster"
  value       = local.cluster_name
}

output "cluster_context" {
  description = "Kubectl context name"
  value       = "k3d-${local.cluster_name}"
}

output "api_endpoint" {
  description = "Kubernetes API endpoint"
  value       = "https://0.0.0.0:${var.api_port}"
}

output "registry_endpoint" {
  description = "Local registry endpoint"
  value       = var.enable_registry ? "localhost:${var.registry_port}" : "Registry not enabled"
}

output "kubeconfig_path" {
  description = "Path to kubeconfig file"
  value       = "~/.kube/config"
}

output "environment" {
  description = "Environment this cluster belongs to"
  value       = var.environment
}