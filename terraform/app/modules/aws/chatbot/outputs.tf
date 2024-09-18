output "slack_channel_configuration_arn" {
  description = "ARN of the AWS Chatbot Slack channel configuration"
  value = awscc_chatbot_slack_channel_configuration.slack_channel_configuration.arn
}
