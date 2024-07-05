locals {
  account_id  = data.aws_caller_identity.current.account_id
  zip         = "lambda_canary.zip"
  canary_name = "${var.project_name}-hearbeat"
}