project_name = "website-prod"
environment  = "prod"
tags = {
  Project     = "website"
  Environment = "prod"
}
domain_name           = "vilnacrm.com"
s3_bucket_custom_name = "vilnacrm.com"

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
  # Keep prod aligned with the staging distribution while CloudFront continuous
  # deployment is enabled; the prod pipeline failed with IllegalUpdate when this
  # drifted higher during the issue #102 rollout.
  minimum_protocol_version = "TLSv1.2_2019"
}

ttl_validation                        = 60
ttl_route53_record                    = 300
s3_noncurrent_version_expiration_days = 365
