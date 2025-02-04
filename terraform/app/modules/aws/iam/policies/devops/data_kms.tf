data "aws_iam_policy_document" "kms_policy_doc" {
  statement {
    sid    = "KMSReadOnlyPolicy"
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:GetKeyPolicy",
      "kms:ListAliases",
      "kms:ListGrants",
      "kms:ListKeyPolicies",
      "kms:ListKeys",
    ]
    resources = [
      "arn:aws:kms::${local.account_id}:*"
    ]
  }
}
