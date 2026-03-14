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
ttl_route53_record = 300

s3_artifacts_bucket_files_deletion_days = 1
s3_noncurrent_version_expiration_days   = 1

s3_logs_lifecycle_configuration = {
  standard_ia_transition_days  = 0
  glacier_transition_days      = 0
  deep_archive_transition_days = 0
  deletion_days                = 1
}

cloudwatch_log_group_retention_days = 1

enable_cloudwatch_alarms  = false
enable_access_logging     = false
enable_waf                = false
enable_canary             = false
enable_cloudfront_staging = false
