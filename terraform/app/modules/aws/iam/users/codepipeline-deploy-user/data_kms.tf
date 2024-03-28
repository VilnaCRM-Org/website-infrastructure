data "aws_iam_policy_document" "kms_policy_doc" {
  statement {
    sid    = "KMSPolicyForCodePipelineUser"
    effect = "Allow"
    actions = [
      "kms:EnableKeyRotation",
      "kms:GetKeyRotationStatus",
      "kms:ListResourceTags",
      "kms:DescribeKey",
      "kms:GetKeyPolicy",
      "kms:PutKeyPolicy",
      "kms:ScheduleKeyDeletion"
    ]
    resources = ["arn:aws:kms:${var.region}:${local.account_id}:key/*"]
  }
} 