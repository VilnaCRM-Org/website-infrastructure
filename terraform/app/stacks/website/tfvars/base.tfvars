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
region        = "eu-central-1"
alias_zone_id = "Z2FDTNDATAQYW2"

s3_logs_lifecycle_configuration = {
  standard_ia_transition_days  = 30
  glacier_transition_days      = 60
  deep_archive_transition_days = 150
  deletion_days                = 365
}

cloudwatch_log_group_retention_days = 7

lambda_python_version                 = "python3.12"
lambda_reserved_concurrent_executions = -1

create_slack_notification = true