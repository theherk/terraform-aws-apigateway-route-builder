output "default_config" {
  description = "Until default optional atributes are implemented using terraform 1.3, this is provided as a glue toward terraform-aws-api-proxy since its method configurations require a specified format. Ideally this module would know nothing about that, but for now this utility is provided."
  value = {
    cache_key_parameters           = null
    cache_namespace                = null
    connection_id                  = null
    connection_type                = null
    content_handling               = null
    credentials                    = null
    integration_request_parameters = null
    method_request_parameters      = null
    passthrough_behavior           = null
    request_templates              = null
    skip_verification              = null
    timeout_milliseconds           = null
    type                           = null
    uri                            = null
  }
}

output "methods" {
  description = "Methods with resource associations and integration configuration."
  value       = local.methods
}

output "resources" {
  description = "Resources keyed by the route's depth and path, and containing: depth, parent_key, path_part."
  value       = local.resources
}
