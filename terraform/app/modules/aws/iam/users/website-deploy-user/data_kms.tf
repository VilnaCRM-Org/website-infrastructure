data "aws_iam_policy_document" "kms_policy_doc" {
  statement {
    sid    = "KMSPolicyForWebsiteUser"
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
  statement {
    sid    = "USKMSPolicyForWebsiteUser"
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
    resources = ["arn:aws:kms:us-east-1:${local.account_id}:key/*"]
  }
} 