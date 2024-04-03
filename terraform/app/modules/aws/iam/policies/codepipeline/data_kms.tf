data "aws_iam_policy_document" "kms_policy_doc" {
  statement {
    sid    = "KMSPolicy"
    effect = "Allow"
    actions = [
      "kms:EnableKeyRotation",
      "kms:GetKeyRotationStatus",
      "kms:ListResourceTags",
      "kms:DescribeKey",
      "kms:GetKeyPolicy",
      "kms:PutKeyPolicy",
      "kms:ScheduleKeyDeletion",
      "kms:TagResource"
    ]
    resources = ["arn:aws:kms:${var.region}:${local.account_id}:key/*"]
  }
} 