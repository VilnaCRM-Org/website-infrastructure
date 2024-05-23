data "aws_iam_policy_document" "sns_bucket_topic_doc" {
  statement {
    sid = "AllowSNSServicePrincipal"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = ["${aws_sns_topic.bucket_notifications.arn}"]

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = [aws_lambda_function.func.arn]
    }
  }

  statement {
    sid     = "AllowSNSPublishIntoTopicForCloudWatch"
    effect  = "Allow"
    actions = ["sns:Publish"]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    resources = ["${aws_sns_topic.bucket_notifications.arn}"]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "${aws_cloudwatch_metric_alarm.s3_objects_anomaly_detection.arn}",
        "${aws_cloudwatch_metric_alarm.s3_requests_anomaly_detection.arn}",
        "${aws_cloudwatch_metric_alarm.s3_4xx_errors_anomaly_detection.arn}",
      ]
    }
  }
}

data "aws_iam_policy_document" "bucket_sns_kms_key_policy_doc" {
  statement {
    sid     = "EnableRootAccessAndPreventPermissionDelegationForS3BucketSNSKMSKey"
    effect  = "Allow"
    actions = ["kms:*"]
    #checkov:skip=CKV_AWS_356:Without this statement, KMS key cannot be managed by root
    resources = ["${aws_kms_key.bucket_sns_encryption_key.arn}"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }

  statement {
    sid       = "AllowAccessForKeyAdministratorsForS3BucketSNSKMSKey"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["${aws_kms_key.bucket_sns_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = [aws_sns_topic.bucket_notifications.arn]
    }
  }
  statement {
    sid    = "AllowUseOfTheKeyForS3BucketSNSKMSKey"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
    ]

    resources = ["${aws_kms_key.bucket_sns_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = [aws_sns_topic.bucket_notifications.arn]
    }
  }
  statement {
    sid    = "AllowUseOfTheKeyForLambdaRoleSNSKMSKey"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey*",
      "kms:Decrypt"
    ]

    resources = ["${aws_kms_key.bucket_sns_encryption_key.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_role.iam_for_lambda.arn}"]
    }
  }
  statement {
    sid    = "AllowUseOfTheKeyForCloudWatchAlarmKMSKey"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey*",
      "kms:Decrypt"
    ]

    resources = ["${aws_kms_key.bucket_sns_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "${aws_cloudwatch_metric_alarm.s3_objects_anomaly_detection.arn}",
        "${aws_cloudwatch_metric_alarm.s3_requests_anomaly_detection.arn}",
        "${aws_cloudwatch_metric_alarm.s3_4xx_errors_anomaly_detection.arn}",
      ]
    }
  }
}