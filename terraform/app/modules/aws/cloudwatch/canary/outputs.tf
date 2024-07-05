output "cloudwatch_sns_topic_arn" {
  value       = aws_sns_topic.cloudwatch_alarm_notifications.arn
  description = "The ARN of SNS Topic of Cloudwatch Alarms"
}
