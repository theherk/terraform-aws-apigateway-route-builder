output "resources" {
  description = "Resources keyed by the route's depth and path, and containing: depth, parent_key, path_part."
  value       = local.resources
}

output "methods" {
  description = "Methods with resource associations and integration configuration."
  value       = local.methods
}
