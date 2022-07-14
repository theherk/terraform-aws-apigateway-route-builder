locals {
  routes = [
    {
      path    = "/v1/{proxy+}"
      methods = ["ANY"]
      config  = { uri = "example.com/v1/{proxy}" }
    },
  ]
}

module "builder" {
  source = "../../../terraform-aws-apigateway-route-builder"

  routes = local.routes
}
