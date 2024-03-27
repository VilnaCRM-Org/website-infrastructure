data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

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
      identifiers = ["logs.us-east-1.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values = [
        "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:aws-waf-logs-wafv2-web-acl"
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
      identifiers = ["logs.us-east-1.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values = [
        "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:aws-waf-logs-wafv2-web-acl"
      ]
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

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "${aws_cloudwatch_metric_alarm.cloudfront-500-errors.arn}",
        "${aws_cloudwatch_metric_alarm.cloudfront-origin-latency.arn}"
      ]
    }
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

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "${aws_sns_topic.cloudwatch_alarm_notifications.arn}"
      ]
    }
  }
  statement {
    sid    = "AllowUseOfTheKeyForCloudWatchAlarmSNSKMSKey"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*"
    ]

    resources = ["${aws_kms_key.cloudwatch_alarm_sns_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "${aws_sns_topic.cloudwatch_alarm_notifications.arn}"
      ]
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

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "${aws_cloudwatch_metric_alarm.cloudfront-500-errors.arn}",
        "${aws_cloudwatch_metric_alarm.cloudfront-origin-latency.arn}"
      ]
    }
  }
}