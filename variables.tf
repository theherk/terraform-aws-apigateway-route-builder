variable "expand_any" {
  description = "Boolean indicating if \"ANY\" methods should be expanded to the full list of http methods. The value of this is in the case custom authorizers. The method that reaches the lambda is \"ANY\" in those cases. However, your policy may want to match the actual http method verb used. This will optionally expand this for you."
  type        = bool
  default     = false
}

variable "generate_base_proxies" {
  description = <<-DESC
    For any routes given with path ending in `{proxy+}` and url ending in `{proxy}`, generate another route for proxying the base route.
    For example, if a route given is:

    ```
    {
      path    = "/v1/{proxy+}"
      methods = ["ANY"]
      config  = { integration = { uri = "example.com/v1/{proxy}" } }
    },
    ```

    and no other routes are given with path "/v1" and url "example.com", then a default base proxy path should be created, such as:

    ```
    {
      path    = "/v1"
      methods = ["ANY"]
      config  = { integration = { uri = "example.com/v1" } }
    },
    ```

    If the preceding statement is not true, then this assumes your explicit configuration is correct.
  DESC
  type        = bool
  default     = true
}

variable "routes" {
  description = "Configuration of routes to proxy. If [\"ANY\"] is given and `expand_any` is given, the module will expand these to all HTTP methods."
  type = list(object({
    path    = string
    methods = list(string)
    config  = map(any)
  }))
}
