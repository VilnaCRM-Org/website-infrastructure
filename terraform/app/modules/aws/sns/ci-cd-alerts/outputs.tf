output "cloudwatch_alerts_sns_topic_arn" {
  value       = aws_sns_topic.cloudwatch_alerts_notifications.arn
  description = "The SNS Topic Arn of the CodePipeline"
}