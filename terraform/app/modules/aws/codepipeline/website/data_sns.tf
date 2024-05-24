data "aws_iam_policy_document" "reports_sns_topic_doc" {
  statement {
    sid = "AllowSNSServicePrincipal"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = ["${aws_sns_topic.reports_notifications.arn}"]

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = [aws_lambda_function.func.arn]
    }
  }
}

data "aws_iam_policy_document" "codepipeline_topic_doc" {
  statement {
    sid     = "AllowSNSPublishIntoTopic"
    effect  = "Allow"
    actions = ["sns:Publish"]

    principals {
      type        = "Service"
      identifiers = ["codestar-notifications.amazonaws.com"]
    }

    resources = ["${aws_sns_topic.codepipeline_notifications.arn}"]
  }
}


data "aws_iam_policy_document" "cloudwatch_reports_sns_topic_doc" {
  statement {
    sid     = "AllowSNSPublishIntoTopicForCloudWatch"
    effect  = "Allow"
    actions = ["sns:Publish"]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    resources = ["${aws_sns_topic.cloudwatch_reports_notifications.arn}"]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "${aws_cloudwatch_metric_alarm.lambda_invocations_anomaly_detection.arn}",
        "${aws_cloudwatch_metric_alarm.lambda_errors_anomaly_detection.arn}",
        "${aws_cloudwatch_metric_alarm.lambda_throttles_anomaly_detection.arn}",
        "${aws_cloudwatch_metric_alarm.lambda_duration_anomaly_detection.arn}",
      ]
    }
  }
}