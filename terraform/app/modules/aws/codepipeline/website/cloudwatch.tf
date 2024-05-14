resource "aws_cloudwatch_log_group" "reports_notification_group" {
  #checkov:skip=CKV_AWS_338: The one year is too much 
  name              = "${var.project_name}-aws-reports-notification-group"
  retention_in_days = var.cloudwatch_log_group_retention_days
  kms_key_id        = aws_kms_key.cloudwatch_encryption_key.arn

  depends_on = [aws_kms_key_policy.cloudwatch_encryption_key]
}