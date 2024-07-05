locals {
  account_id                                 = data.aws_caller_identity.current.account_id
  lambda_reports_notifications_function_name = "${var.project_name}-reports-notification"
}
