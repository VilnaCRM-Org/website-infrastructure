resource "awscc_chatbot_slack_channel_configuration" "slack_channel_configuration" {
  configuration_name = "${var.project_name}-slack-conf"
  iam_role_arn       = awscc_iam_role.chatbot_role.arn
  slack_channel_id   = var.channel_id
  slack_workspace_id = var.workspace_id
  sns_topic_arns     = var.sns_topic_arns
}

resource "awscc_iam_role" "chatbot_role" {
  role_name = "${var.project_name}-chatbot-channel-role"
  assume_role_policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "chatbot.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSResourceExplorerReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSCodePipelineReadOnlyAccess",
    "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
  ]
}