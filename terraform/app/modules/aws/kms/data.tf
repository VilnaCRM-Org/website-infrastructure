data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "kms_key_policy_doc" {
  statement {
    sid     = "EnableRootAccessAndPreventPermissionDelegation"
    effect  = "Allow"
    actions = ["kms:*"]
    #checkov:skip=CKV_AWS_356:Without this statement, KMS key cannot be managed by root
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }

  statement {
    sid       = "AllowAccessForKeyAdministrators"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["${aws_kms_key.encryption_key.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${var.codepipeline_role_arn}"]
    }
  }

  statement {
    sid    = "AllowUseOfTheKey"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = ["${aws_kms_key.encryption_key.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${var.codepipeline_role_arn}"]
    }
  }

  statement {
    sid    = "AllowAttachmentOfPersistentResources"
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = ["${aws_kms_key.encryption_key.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${var.codepipeline_role_arn}"]
    }

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}