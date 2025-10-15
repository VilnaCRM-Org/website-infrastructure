resource "awscc_chatbot_slack_channel_configuration" "slack_channel_configuration" {
  configuration_name = "${var.project_name}-slack-conf"
  iam_role_arn       = awscc_iam_role.chatbot_role.arn
  slack_channel_id   = var.channel_id
  slack_workspace_id = var.workspace_id
  sns_topic_arns     = var.sns_topic_arns
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

#checkov:skip=CKV_AWS_356:Chatbot requires wildcard access to discover and read all pipelines for monitoring purposes
data "aws_iam_policy_document" "chatbot_codepipeline_policy" {
  statement {
    sid    = "CodePipelineReadOnly"
    effect = "Allow"
    actions = [
      "codepipeline:GetPipeline",
      "codepipeline:GetPipelineState",
      "codepipeline:GetPipelineExecution",
      "codepipeline:ListPipelines",
      "codepipeline:ListPipelineExecutions",
      "codepipeline:ListActionExecutions",
      "codepipeline:ListTagsForResource"
    ]
    resources = [
      "arn:aws:codepipeline:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }
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
    "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
  ]
  policies = [
    {
      policy_document = data.aws_iam_policy_document.chatbot_codepipeline_policy.json
      policy_name     = "${var.project_name}-chatbot-codepipeline-policy"
    }
  ]
}