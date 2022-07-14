locals {
  routes = [
    {
      path    = "/v1"
      methods = ["POST"]
      config = {
        uri    = "example.com/v1"
        attr_a = "only base proxy POST"
      }
    },
    {
      path    = "/v1/{proxy+}"
      methods = ["GET"]
      config = {
        attr_a = "more explicit than expanded ANY"
      }
    },
    {
      path    = "/v1/{proxy+}"
      methods = ["ANY"]
      config = {
        uri    = "example.com/v1/{proxy}"
        attr_a = "applies to all expanded"
      }
    },
  ]
}

module "builder" {
  source = "../../../terraform-aws-apigateway-route-builder"

  expand_any            = true
  generate_base_proxies = false
  routes                = local.routes
}
