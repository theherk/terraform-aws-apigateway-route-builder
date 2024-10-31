locals {
  routes = [
    {
      path    = "v1/foo/bar/baz"
      methods = ["GET", "OPTIONS"]
      config  = { uri = "example.com/v1/foo/bar/baz" }
    },
  ]
}

module "builder" {
  source = "../../../terraform-aws-apigateway-route-builder"

  routes = local.routes
}
