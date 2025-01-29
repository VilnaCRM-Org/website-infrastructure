resource "aws_sns_topic" "cloudwatch_alarm_notifications" {
  #checkov:skip=CKV_AWS_26: KMS encryption is not needed
  name = "${var.project_name}-cloudwatch-alarm-notifications"

  tags = var.tags
}

resource "aws_sns_topic_policy" "cloudwatch_alarm_notifications" {
  arn    = aws_sns_topic.cloudwatch_alarm_notifications.arn
  policy = data.aws_iam_policy_document.cloudwatch_alarm_sns_topic_doc.json

  depends_on = [aws_sns_topic.cloudwatch_alarm_notifications]
}

