data "aws_iam_policy_document" "cloudtrail_kms_key_policy_doc" {
  statement {
    sid     = "EnableRootAccessAndPreventPermissionDelegationForCloudWatchLogsKMSKey"
    effect  = "Allow"
    actions = ["kms:*"]
    #checkov:skip=CKV_AWS_356:Without this statement, KMS key cannot be managed by root
    resources = ["${aws_kms_key.cloudtrail_encryption_key.arn}"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }

  statement {
    sid       = "AllowAccessForKeyAdministratorsForCloudWatchLogsKMSKey"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["${aws_kms_key.cloudtrail_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values = [
        "arn:aws:cloudtrail:${var.region}:${local.account_id}:trail/${var.project_name}-dynamodb-cloudtrail"
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

    resources = ["${aws_kms_key.cloudtrail_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values = [
        "arn:aws:cloudtrail:${var.region}:${local.account_id}:trail/${var.project_name}-dynamodb-cloudtrail"
      ]
    }
  }
}
