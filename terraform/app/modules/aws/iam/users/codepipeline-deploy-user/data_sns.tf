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
    resources = ["arn:aws:sns:${var.region}:${local.account_id}:${var.project_name}-notifications"]
  }
} 