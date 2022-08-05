locals {
  http_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]

  # Process routes into a suitable data structure for api resources.
  # For each route, ensure ANY is expanded if an authorizer is in use.
  # Trim paths, identify final path part, and identify predecessors.
  routes_processed = [for r in var.routes : {
    config       = r.config
    methods      = var.expand_any && contains(r.methods, "ANY") ? toset(local.http_methods) : toset(r.methods)
    path         = trim(r.path, "/")
    path_part    = element(split("/", trim(r.path, "/")), length(split("/", trim(r.path, "/"))) - 1)
    predecessors = slice(split("/", trim(r.path, "/")), 0, length(split("/", trim(r.path, "/"))) - 1)
    resource_key = join("|", [length(split("/", trim(r.path, "/"))) - 1, trim(r.path, "/")])
  }]

  # Generate base proxy defaults for all routes given where both the path
  # ends with {proxy+} and the url ends with {proxy}. The purpose is to
  # automatically configure routing at the base routes.
  # For example, if a route given is:
  # {
  #   path    = "/v1/{proxy+}"
  #   methods = ["ANY"]
  #   config  = { uri = "example.com/v1/{proxy}" }
  # },
  # and no other routes are given with path "/v1" and url "example.com",
  # then a default base proxy path should be created, such as:
  # {
  #   path    = "/v1"
  #   methods = ["ANY"]
  #   config  = { uri = "example.com/v1" }
  # },
  # If the preceding statement is not true, then this assumes your
  # explicit configuration is correct.
  default_base_proxies = !var.generate_base_proxies ? [] : [for r in local.routes_processed : {
    config       = merge(r.config, { uri = trim(split("{proxy}", trim(lookup(r.config, "uri", ""), "/"))[0], "/") })
    methods      = r.methods
    path         = length(r.predecessors) > 0 ? join("/", slice(r.predecessors, 0, length(r.predecessors) - 1)) : ""
    path_part    = length(r.predecessors) > 0 ? r.predecessors[length(r.predecessors) - 1] : ""
    predecessors = length(r.predecessors) > 0 ? slice(r.predecessors, 0, length(r.predecessors) - 1) : []
    resource_key = join("|", [length(r.predecessors) > 0 ? length(r.predecessors) - 1 : 0, join("/", slice(r.predecessors, 0, length(r.predecessors)))])
    } if alltrue([
      length(split("{proxy+}", r.path)) == 2,
      length(split("{proxy}", lookup(r.config, "uri", "") != "" ? trim(lookup(r.config, "uri", ""), "/") : "")) == 2,
    ])
  ]

  # For each predecessor of each route, add a default route object.
  # This ensures that a resource will exist even if routes for the
  # predecessors are not explicitly declared. If they are declared,
  # there is no conflict.
  default_predecessors = flatten([for r in local.routes_processed : [for i in range(length(r.predecessors)) : {
    config       = {}
    methods      = []
    path         = join("/", slice(r.predecessors, 0, i + 1))
    path_part    = r.predecessors[i]
    predecessors = i > 0 ? slice(r.predecessors, i - 1, i) : []
    resource_key = join("|", [i, join("/", slice(r.predecessors, 0, i + 1))])
  }]])

  # Combination of the routes given explicitly, which are first and take
  # precedence, default base proxies if requested, and predecessors.
  routes = concat(local.routes_processed, local.default_base_proxies, local.default_predecessors)

  # Build an object of resources keyed by the route's depth and path, and
  # containing: depth, parent_key, path_part.
  resources = { for k in distinct([for r in local.routes : r.resource_key]) : k => [
    for r in local.routes : {
      path_part = r.path_part

      depth = length(r.predecessors)
      parent_key = (length(r.predecessors) != 0
        ? join("|", [length(r.predecessors) - 1, join("/", r.predecessors)])
        : null
      )
    } if r.resource_key == k][0]
  }

  # All resource methods, including overlap.
  # So including those specified explicitly and those generated as base
  # proxy methods. The methods local will select the most explicit of
  # these two for the object used within the module. In this way, a user
  # could specify any method at the same root as a generated base proxy
  # and if ANY were expanded to the list of http methods, those not
  # explicitly specified would be included in addition to the explicit
  # definition.
  method_list = flatten([
    for r in local.routes : [
      for m in r.methods : {
        config       = r.config
        depth        = length(r.predecessors)
        key          = join("|", [r.resource_key, m])
        method       = m
        resource_key = r.resource_key
        root         = length(r.predecessors) == 0 && length(r.path_part) == 0
      }
    ]
  ])

  # As noted in method_list, this builds an object selecting the most
  # explicit of a given routes methods.
  methods = { for k in distinct([for m in local.method_list : m.key]) : k => [
    for m in local.method_list : m if m.key == k
  ][0] }
}
