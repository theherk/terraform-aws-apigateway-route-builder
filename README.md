# aws apigateway route builder

Terraform module to convert routes to structured resources and methods with predecessors where required.

## Usage

```hcl
module "route_builder" {
  source = ""

  routes = [
    {
      path    = "/v1"
      methods = []
      config  = { integration = {} }
    },
    {
      path    = "/v1/{proxy+}"
      methods = ["ANY"]
      config  = { integration = { uri = "example.com/v1/{proxy}" } }
    },
    {
      path    = "/v1/{proxy+}"
      methods = ["ANY"]
      config = { integration = {
        connection_type = "VPC_LINK"
        uri             = "example.com/v1/{proxy}"
      } }
    },
    {
      path    = "/v1/pdf"
      methods = ["POST"]
      config = { integration = {
        type = "AWS_PROXY"
        uri  = "arn:aws:lambda:eu-west-1:123412341234:function:mylambda"
      } }
    },
  ]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_expand_any"></a> [expand\_any](#input\_expand\_any) | Boolean indicating if "ANY" methods should be expanded to the full list of http methods. The value of this is in the case custom authorizers. The method that reaches the lambda is "ANY" in those cases. However, your policy may want to match the actual http method verb used. This will optionally expand this for you. | `bool` | `false` | no |
| <a name="input_generate_base_proxies"></a> [generate\_base\_proxies](#input\_generate\_base\_proxies) | For any routes given with path ending in `{proxy+}` and url ending in `{proxy}`, generate another route for proxying the base route.<br>For example, if a route given is:<pre>{<br>  path    = "/v1/{proxy+}"<br>  methods = ["ANY"]<br>  config  = { integration = { uri = "example.com/v1/{proxy}" } }<br>},</pre>and no other routes are given with path "/v1" and url "example.com", then a default base proxy path should be created, such as:<pre>{<br>  path    = "/v1"<br>  methods = ["ANY"]<br>  config  = { integration = { uri = "example.com/v1" } }<br>},</pre>If the preceding statement is not true, then this assumes your explicit configuration is correct. | `bool` | `true` | no |
| <a name="input_routes"></a> [routes](#input\_routes) | Configuration of routes to proxy. If ["ANY"] is given and `expand_any` is given, the module will expand these to all HTTP methods. | <pre>list(object({<br>    path    = string<br>    methods = list(string)<br>    config  = map(any)<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_methods"></a> [methods](#output\_methods) | Methods with resource associations and integration configuration. |
| <a name="output_resources"></a> [resources](#output\_resources) | Resources keyed by the route's depth and path, and containing: depth, parent\_key, path\_part. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
