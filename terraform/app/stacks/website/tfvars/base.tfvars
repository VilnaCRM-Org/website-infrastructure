region        = "eu-central-1"
alias_zone_id = "Z2FDTNDATAQYW2"

# Next.js exports /en as /en.html. Pin the matching routing function so both
# CloudFront distributions receive the same reviewed code in test and prod.
cloudfront_routing_function_revision = "c8f0a755b101bab45b49232f91641362cd0d1cbc"

s3_logs_lifecycle_configuration = {
  standard_ia_transition_days  = 30
  glacier_transition_days      = 60
  deep_archive_transition_days = 150
  deletion_days                = 365
}

canary_configuration = {
  runtime_version          = "syn-python-selenium-6.0"
  frequency                = 480
  take_screenshot          = false
  success_retention_period = 2
  failure_retention_period = 14
}

s3_artifacts_bucket_files_deletion_days = 7
s3_noncurrent_version_expiration_days   = 365

cloudwatch_log_group_retention_days = 7

lambda_configuration = {
  python_version                 = "python3.12"
  reserved_concurrent_executions = -1
}

create_slack_notification = true

enable_cloudfront_staging = true
enable_cloudwatch_alarms  = true
enable_waf                = true
