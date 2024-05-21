resource "aws_synthetics_canary" "canary_api_calls" {
  name                 = "${var.project_name}-hearbeat"
  artifact_s3_location = "s3://${var.canaries_reports_bucket_id}/"
  execution_role_arn   = var.canaries_iam_role_arn
  runtime_version      = var.canary_configuration.runtime_version
  handler              = "canary.handler"
  zip_file             = local.zip
  start_canary         = true
  delete_lambda        = true

  success_retention_period = var.canary_configuration.success_retention_period
  failure_retention_period = var.canary_configuration.failure_retention_period

  schedule {
    expression          = "cron(0 */8 * * ? *)"
    duration_in_seconds = 0
  }

  run_config {
    timeout_in_seconds = 15
    active_tracing     = false
    environment_variables = {
      URL             = "https://${var.domain_name}"
      TAKE_SCREENSHOT = var.canary_configuration.take_screenshot
    }
  }


  tags = var.tags

  depends_on = [
    data.archive_file.lambda_canary_zip,
  ]

}