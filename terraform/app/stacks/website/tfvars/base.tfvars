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

canary_configuration = {
  runtime_version          = "syn-python-selenium-3.0"
  frequency                = 480
  take_screenshot          = false
  success_retention_period = 2
  failure_retention_period = 14
}

s3_artifacts_bucket_files_deletion_days = 7

cloudwatch_log_group_retention_days = 7

lambda_python_version                 = "python3.12"
lambda_reserved_concurrent_executions = -1

create_slack_notification = true