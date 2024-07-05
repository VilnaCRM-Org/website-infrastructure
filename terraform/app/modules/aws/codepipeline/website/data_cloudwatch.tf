data "aws_iam_policy_document" "cloudwatch_kms_key_policy_doc" {
  statement {
    sid     = "EnableRootAccessAndPreventPermissionDelegationForCloudWatchLogsKMSKey"
    effect  = "Allow"
    actions = ["kms:*"]
    #checkov:skip=CKV_AWS_356:Without this statement, KMS key cannot be managed by root
    resources = ["${aws_kms_key.cloudwatch_encryption_key.arn}"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }

  statement {
    sid       = "AllowAccessForKeyAdministratorsForCloudWatchLogsKMSKey"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["${aws_kms_key.cloudwatch_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["logs.${var.region}.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values = [
        "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${var.project_name}-aws-reports-notification-group"
      ]
    }
  }

  statement {
    sid    = "AllowUseOfTheKeyCloudWatchLogsKMSKey"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*"
    ]

    resources = ["${aws_kms_key.cloudwatch_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["logs.${var.region}.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values = [
        "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${var.project_name}-aws-reports-notification-group"
      ]
    }
  }
}
