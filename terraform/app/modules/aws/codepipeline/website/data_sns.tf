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
