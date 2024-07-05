data "aws_iam_policy_document" "sns_policy_doc" {
  statement {
    sid    = "SNSPolicy"
    effect = "Allow"
    actions = [
      "sns:CreateTopic",
      "sns:SetTopicAttributes",
      "sns:GetTopicAttributes",
      "sns:ListTagsForResource",
      "sns:TagResource",
      "sns:DeleteTopic"
    ]
    resources = [
      "arn:aws:sns:${var.region}:${local.account_id}:${var.project_name}-bucket-notifications",
      "arn:aws:sns:${var.region}:${local.account_id}:${var.project_name}-staging-bucket-notifications",
      "arn:aws:sns:${var.region}:${local.account_id}:${var.project_name}-cloudwatch-alarm-notifications",
      "arn:aws:sns:us-east-1:${local.account_id}:${var.project_name}-cloudwatch-alarm-notifications"
    ]
  }
  statement {
    sid    = "ChatformationForChatBotPolicy"
    effect = "Allow"
    actions = [
      "cloudformation:CreateResource",
      "cloudformation:GetResource",
      "cloudformation:ListTagsForResource",
      "cloudformation:TagResource",
      "cloudformation:GetResourceRequestStatus",
      "cloudformation:DeleteResource"
    ]
    resources = ["arn:aws:cloudformation:${var.region}:${local.account_id}:resource/*"]
  }
  statement {
    sid    = "ChatbotGeneralSlackPolicy"
    effect = "Allow"
    actions = [
      "chatbot:DescribeSlackChannelConfigurations",
      "chatbot:UpdateSlackChannelConfiguration",
      "chatbot:DeleteSlackChannelConfiguration",
      "chatbot:CreateSlackChannelConfiguration",
    ]
    #checkov:skip=CKV_AWS_356:Required by AWSCC module
    #checkov:skip=CKV_AWS_111:Required by AWSCC module
    resources = ["*"]
  }
} 