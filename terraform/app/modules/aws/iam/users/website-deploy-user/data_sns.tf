data "aws_iam_policy_document" "sns_policy_doc" {
  statement {
    sid    = "SNSPolicyForWebsiteUser"
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
      "arn:aws:sns:us-east-1:${local.account_id}:${var.project_name}-cloudwatch-alarm-notifications"
    ]
  }
} 