resource "aws_sns_topic" "cloudwatch_alarm_notifications" {
  #checkov:skip=CKV_AWS_26: KMS encryption is not needed
  provider = aws.us-east-1
  name     = "${var.project_name}-cloudwatch-alarm-notifications"

  tags = var.tags
}

resource "aws_sns_topic_policy" "cloudwatch_alarm_notifications" {
  provider = aws.us-east-1
  arn      = aws_sns_topic.cloudwatch_alarm_notifications.arn
  policy   = data.aws_iam_policy_document.cloudwatch_alarm_sns_topic_doc.json

  depends_on = [aws_sns_topic.cloudwatch_alarm_notifications]
}

