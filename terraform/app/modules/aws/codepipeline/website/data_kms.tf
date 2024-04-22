data "aws_iam_policy_document" "codepipeline_sns_kms_key_policy_doc" {
  statement {
    sid     = "EnableRootAccessAndPreventPermissionDelegationForCodePipelineSNSKMSKey"
    effect  = "Allow"
    actions = ["kms:*"]
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
    actions   = ["kms:*"]
    resources = ["${aws_kms_key.codepipeline_sns_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "${aws_sns_topic.codepipeline_notifications.arn}"
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
        "${aws_sns_topic.codepipeline_notifications.arn}"
      ]
    }
  }
  statement {
    sid    = "AllowUseOfTheKeyForCodeStarNotificationKMSKey"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey*",
      "kms:Decrypt"
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

data "aws_iam_policy_document" "lhci_reports_sns_kms_key_policy_doc" {
  statement {
    sid     = "EnableRootAccessAndPreventPermissionDelegationForS3BucketSNSKMSKey"
    effect  = "Allow"
    actions = ["kms:*"]
    #checkov:skip=CKV_AWS_356:Without this statement, KMS key cannot be managed by root
    resources = ["${aws_kms_key.lhci_reports_sns_encryption_key.arn}"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }

  statement {
    sid       = "AllowAccessForKeyAdministratorsForS3BucketSNSKMSKey"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["${aws_kms_key.lhci_reports_sns_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = [aws_sns_topic.lhci_reports_notifications.arn]
    }
  }
  statement {
    sid    = "AllowUseOfTheKeyForS3BucketSNSKMSKey"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
    ]

    resources = ["${aws_kms_key.lhci_reports_sns_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = [aws_sns_topic.lhci_reports_notifications.arn]
    }
  }
  statement {
    sid    = "AllowUseOfTheKeyForLambdaRoleSNSKMSKey"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey*",
      "kms:Decrypt"
    ]

    resources = ["${aws_kms_key.lhci_reports_sns_encryption_key.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_role.iam_for_lambda.arn}"]
    }
  }
}