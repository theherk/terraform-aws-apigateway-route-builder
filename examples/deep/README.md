# Example - Deep

A bug was discovered where the depth calculation was incorrect for paths with more than two segments. This example was added to verify the fix.

## The resulting outputs are:

### resources

``` hcl
resources = {
  "0|v1" = {
    depth      = 0
    parent_key = null
    path_part  = "v1"
  }
  "1|v1/foo" = {
    depth      = 1
    parent_key = "0|v1"
    path_part  = "foo"
  }
  "2|v1/foo/bar" = {
    depth      = 2
    parent_key = "1|v1/foo"
    path_part  = "bar"
  }
  "3|v1/foo/bar/baz" = {
    depth      = 3
    parent_key = "2|v1/foo/bar"
    path_part  = "baz"
  }
}
```

### methods

``` hcl
methods = {
  "3|v1/foo/bar/baz|GET" = {
    config = {
      uri = "example.com/v1/foo/bar/baz"
    }
    depth        = 3
    key          = "3|v1/foo/bar/baz|GET"
    method       = "GET"
    resource_key = "3|v1/foo/bar/baz"
    root         = false
  }
  "3|v1/foo/bar/baz|OPTIONS" = {
    config = {
      uri = "example.com/v1/foo/bar/baz"
    }
    depth        = 3
    key          = "3|v1/foo/bar/baz|OPTIONS"
    method       = "OPTIONS"
    resource_key = "3|v1/foo/bar/baz"
    root         = false
  }
}
```
