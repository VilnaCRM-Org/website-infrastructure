data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_iam_policy_document" "general_policy_doc" {
  statement {
    sid    = "GeneralPolicyForCodePipelineUser"
    effect = "Allow"
    actions = [
      "sts:GetCallerIdentity",
      "kms:CreateKey",
      "codestar-notifications:DeleteTarget"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "GeneralSecretsPolicyForCodePipelineUser" # To remove in new implementation of tokens
    effect = "Allow"
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetResourcePolicy"
    ]
    resources = ["arn:aws:secretsmanager:${var.region}:${local.account_id}:secret:test/AWS/*"]
  }
} 