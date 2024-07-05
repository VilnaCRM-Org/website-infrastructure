resource "aws_sns_topic" "cloudwatch_alerts_notifications" {
  name = "${var.project_name}-cloudwatch-alerts-notifications"

  kms_master_key_id = aws_kms_key.cloudwatch_alerts_sns_encryption_key.id

  tags = var.tags

  depends_on = [aws_kms_key.cloudwatch_alerts_sns_encryption_key]
}

resource "aws_sns_topic_policy" "cloudwatch_alerts_notifications" {
  arn    = aws_sns_topic.cloudwatch_alerts_notifications.arn
  policy = data.aws_iam_policy_document.cloudwatch_alerts_sns_topic_doc.json

  depends_on = [aws_sns_topic.cloudwatch_alerts_notifications]
}