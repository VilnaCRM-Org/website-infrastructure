locals {
  account_id                            = data.aws_caller_identity.current.account_id
  allow_force_destroy                   = var.environment == "test" ? true : false
  lambda_s3_notifications_function_name = "${var.project_name}-website-infra-s3-notifications"
}