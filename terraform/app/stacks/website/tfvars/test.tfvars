project_name = "website-test"
environment  = "test"
tags = {
  Project     = "website"
  Environment = "test"
}
domain_name           = "vilnacrmtest.com"
s3_bucket_custom_name = "vilnacrmtest.com"

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

cloudfront_configuration = {
  price_class                = "PriceClass_100"
  min_ttl                    = 0
  default_ttl                = 86400
  max_ttl                    = 31536000
  access_control_max_age_sec = 31536000
  default_root_object        = "index.html"
  minimum_protocol_version   = "TLSv1.2_2019"
}

ttl_validation     = 60
ttl_route53_record = "300"