data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_iam_policy_document" "codepipeline_sns_kms_key_policy_doc" {
  statement {
    sid    = "EnableRootAccessAndPreventPermissionDelegationForCodePipelineSNSKMSKey"
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:EnableKey",
      "kms:DisableKey",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
      "kms:List*"
    ]
    #checkov:skip=CKV_AWS_356:Without this statement, KMS key cannot be managed by root
    resources = ["${aws_kms_key.codepipeline_sns_encryption_key.arn}"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }

  statement {
    sid       = "AllowAccessForKeyAdministratorsForCodePipelineSNSKMSKey"
    effect    = "Allow"
    actions   = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["${aws_kms_key.codepipeline_sns_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        local.sns_topic_arn
      ]
    }
  }

  statement {
    sid    = "AllowUseOfTheKeyForCodePipelineSNSKMSKey"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*"
    ]

    resources = ["${aws_kms_key.codepipeline_sns_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        local.sns_topic_arn
      ]
    }
  }

  statement {
    sid    = "AllowUseOfTheKeyForCodeStarNotificationKMSKey"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*"
    ]

    resources = ["${aws_kms_key.codepipeline_sns_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["codestar-notifications.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "sns.${var.region}.amazonaws.com"
      ]
    }
  }
}