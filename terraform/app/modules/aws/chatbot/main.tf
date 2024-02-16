resource "awscc_chatbot_slack_channel_configuration" "slack_channel_configuration" {
  configuration_name = "${var.project_name}-slack-conf"
  iam_role_arn       = awscc_iam_role.chatbot_role.arn
  slack_channel_id   = var.channel_id
  slack_workspace_id = var.workspace_id
  sns_topic_arns     = [var.sns_topic_arn]
}

resource "awscc_iam_role" "chatbot_role" {
  role_name                   = "${var.project_name}-chatbot-channel-role"
  assume_role_policy_document = data.aws_iam_policy_document.chatbot_role_assume_role_policy_doc.json
  policies = [{
    policy_document = data.aws_iam_policy_document.kms_key_access_doc.json
    policy_name     = "kms_key_access"
    }
  ]
  managed_policy_arns = ["arn:aws:iam::aws:policy/AWSResourceExplorerReadOnlyAccess"]
}