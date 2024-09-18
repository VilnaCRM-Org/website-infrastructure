locals {
  account_id = data.aws_caller_identity.current.account_id
  sns_topic_arn = aws_sns_topic.codepipeline_notifications.arn
}
