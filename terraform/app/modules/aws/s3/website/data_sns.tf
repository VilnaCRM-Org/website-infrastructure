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
      values   = var.staging == true ? local.sns_staging_alarms : local.sns_alarms
    }
  }
}
