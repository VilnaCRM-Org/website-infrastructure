resource "aws_sns_topic" "cloudwatch_alarm_notifications" {
  name = "${var.project_name}-cloudwatch-alarm-notifications"

  kms_master_key_id = aws_kms_key.cloudwatch_alarm_sns_encryption_key.id

  tags = var.tags

  depends_on = [aws_kms_key.cloudwatch_alarm_sns_encryption_key]
}

resource "aws_sns_topic_policy" "cloudwatch_alarm_notifications" {
  arn    = aws_sns_topic.cloudwatch_alarm_notifications.arn
  policy = data.aws_iam_policy_document.cloudwatch_alarm_sns_topic_doc.json

  depends_on = [aws_sns_topic.cloudwatch_alarm_notifications]
}

