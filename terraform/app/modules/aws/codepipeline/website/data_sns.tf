data "aws_iam_policy_document" "reports_sns_topic_doc" {
  statement {
    sid = "AllowSNSServicePrincipal"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [local.reports_notifications_topic_arn]

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = [local.lambda_reports_notifications_function_arn]
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

    resources = [local.codepipeline_notifications_topic_arn]
  }
}
