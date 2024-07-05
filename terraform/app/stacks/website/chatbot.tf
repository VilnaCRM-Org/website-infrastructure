module "chatbot" {
  count = var.create_slack_notification ? 1 : 0

  source = "../../modules/aws/chatbot"

  project_name = "website-cloudfront-failover-alarm"
  channel_id   = var.WEBSITE_ALERTS_SLACK_CHANNEL_ID
  workspace_id = var.SLACK_WORKSPACE_ID
  sns_topic_arns = [
    module.cloudfront.cloudwatch_sns_topic_arn,
    module.s3_bucket.bucket_notifications_arn,
    module.canary.cloudwatch_sns_topic_arn
  ]

  tags = var.tags
}