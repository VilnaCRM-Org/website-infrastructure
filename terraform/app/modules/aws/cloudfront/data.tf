data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_iam_policy_document" "cloudwatch_kms_key_policy_doc" {
  statement {
    sid     = "EnableRootAccessAndPreventPermissionDelegationForCloudWatchSNSKMSKey"
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
    sid       = "AllowAccessForKeyAdministratorsForCloudWatchSNSKMSKey"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["${aws_kms_key.cloudwatch_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["logs.us-east-1.amazonaws.com"]
    }
  }
  statement {
    sid    = "AllowUseOfTheKeyForCloudwatchKMSKey"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = ["${aws_kms_key.cloudwatch_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["logs.us-east-1.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cloudwatch_alarm_sns_topic_doc" {
  statement {
    sid     = "AllowSNSPublishIntoTopicForCloudWatch"
    effect  = "Allow"
    actions = ["sns:Publish"]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    resources = ["${aws_sns_topic.cloudwatch_alarm_notifications.arn}"]
  }
}

data "aws_iam_policy_document" "cloudwatch_alarm_sns_kms_key_policy_doc" {
  statement {
    sid     = "EnableRootAccessAndPreventPermissionDelegationForCloudWatchAlarmSNSKMSKey"
    effect  = "Allow"
    actions = ["kms:*"]
    #checkov:skip=CKV_AWS_356:Without this statement, KMS key cannot be managed by root
    resources = ["${aws_kms_key.cloudwatch_alarm_sns_encryption_key.arn}"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }

  statement {
    sid       = "AllowAccessForKeyAdministratorsForCloudWatchAlarmSNSKMSKey"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["${aws_kms_key.cloudwatch_alarm_sns_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
  }
  statement {
    sid    = "AllowUseOfTheKeyForCloudWatchAlarmSNSKMSKey"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = ["${aws_kms_key.cloudwatch_alarm_sns_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
  }
  statement {
    sid    = "AllowUseOfTheKeyForCloudWatchAlarmKMSKey"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey*",
      "kms:Decrypt"
    ]

    resources = ["${aws_kms_key.cloudwatch_alarm_sns_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
  }
}