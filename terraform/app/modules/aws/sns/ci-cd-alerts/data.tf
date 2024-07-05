data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_iam_policy_document" "cloudwatch_alerts_sns_topic_doc" {
  statement {
    sid     = "AllowSNSPublishIntoTopicForCloudWatch"
    effect  = "Allow"
    actions = ["sns:Publish"]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    resources = ["${aws_sns_topic.cloudwatch_alerts_notifications.arn}"]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = var.cloudwatch_alarms_arns
    }
  }
}

data "aws_iam_policy_document" "cloudwatch_alerts_sns_encryption_key_policy_doc" {
  statement {
    sid     = "EnableRootAccessAndPreventPermissionDelegationForS3BucketSNSKMSKey"
    effect  = "Allow"
    actions = ["kms:*"]
    #checkov:skip=CKV_AWS_356:Without this statement, KMS key cannot be managed by root
    resources = ["${aws_kms_key.cloudwatch_alerts_sns_encryption_key.arn}"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }

  statement {
    sid       = "AllowAccessForKeyAdministratorsForS3BucketSNSKMSKey"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["${aws_kms_key.cloudwatch_alerts_sns_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = [aws_sns_topic.cloudwatch_alerts_notifications.arn]
    }
  }
  statement {
    sid    = "AllowUseOfTheKeyForS3BucketSNSKMSKey"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
    ]

    resources = ["${aws_kms_key.cloudwatch_alerts_sns_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = [aws_sns_topic.cloudwatch_alerts_notifications.arn]
    }
  }
  statement {
    sid    = "AllowUseOfTheKeyForCloudWatchAlarmKMSKey"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey*",
      "kms:Decrypt"
    ]

    resources = ["${aws_kms_key.cloudwatch_alerts_sns_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = var.cloudwatch_alarms_arns
    }
  }
}