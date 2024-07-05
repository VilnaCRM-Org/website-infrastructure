data "aws_iam_policy_document" "kms_policy_doc" {
  statement {
    sid    = "KMSPolicy"
    effect = "Allow"
    actions = [
      "kms:GetParametersForImport",
      "kms:DescribeCustomKeyStores",
      "kms:ListKeys",
      "kms:GetPublicKey",
      "kms:ListKeyPolicies",
      "kms:ListRetirableGrants",
      "kms:GetKeyRotationStatus",
      "kms:ListAliases",
      "kms:GetKeyPolicy",
      "kms:DescribeKey",
      "kms:ListResourceTags",
      "kms:ListGrants"
    ]
    resources = [
      "arn:aws:kms:${var.region}:${local.account_id}:key/*",
      "arn:aws:kms:us-east-1:${local.account_id}:key/*"
    ]
  }
} 