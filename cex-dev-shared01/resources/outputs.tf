output "namespaces_created" {
  description = "List of created namespaces"
  value       = [for ns in kubernetes_namespace.namespaces : ns.metadata[0].name]
}

output "resource_quotas" {
  description = "Resource quotas per namespace"
  value = {
    for ns, quota in kubernetes_resource_quota. namespace_quotas : 
    ns => quota.spec[0].hard
  }
}
