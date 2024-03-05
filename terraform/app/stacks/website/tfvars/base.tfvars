cloudfront_default_root_object      = "index.html"
cloudfront_minimum_protocol_version = "TLSv1.2_2019"
cloudfront_custom_error_responses = [
  {
    error_code            = 403
    response_code         = 404
    error_caching_min_ttl = 10
    response_page_path    = "/index.html"
  },
  {
    error_code            = 404
    response_code         = 404
    error_caching_min_ttl = 10
    response_page_path    = "/index.html"
  }
]
region                      = "eu-central-1"
alias_zone_id = "Z2FDTNDATAQYW2"