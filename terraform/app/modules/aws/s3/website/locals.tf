locals {
  account_id                            = data.aws_caller_identity.current.account_id
  allow_force_destroy                   = var.environment == "test" ? true : false
  lambda_s3_notifications_function_name = "${var.project_name}-website-infra-s3-notifications"

  sns_staging_alarms = ["arn:aws:cloudwatch:${var.region}:${local.account_id}:alarm:${var.project_name}-s3-4xx-errors-anomaly-detection", ]

  sns_alarms = [
    "arn:aws:cloudwatch:${var.region}:${local.account_id}:alarm:${var.project_name}-s3-objects-anomaly-detection",
    "arn:aws:cloudwatch:${var.region}:${local.account_id}:alarm:${var.project_name}-s3-requests-anomaly-detection",
    "arn:aws:cloudwatch:${var.region}:${local.account_id}:alarm:${var.project_name}-s3-4xx-errors-anomaly-detection",
    "arn:aws:cloudwatch:${var.region}:${local.account_id}:alarm:${var.project_name}-lambda-s3-invocations-anomaly-detection",
    "arn:aws:cloudwatch:${var.region}:${local.account_id}:alarm:${var.project_name}-lambda-s3-errors-detection",
    "arn:aws:cloudwatch:${var.region}:${local.account_id}:alarm:${var.project_name}-lambda-s3-throttles-anomaly-detection",
    "arn:aws:cloudwatch:${var.region}:${local.account_id}:alarm:${var.project_name}-lambda-s3-duration-anomaly-detection",
  ]

}