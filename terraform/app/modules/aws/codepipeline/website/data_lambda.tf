data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_allow_sns_policy" {
  statement {
    effect = "Allow"
    sid    = "AllowPublishMessageToSNS"

    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.reports_notifications.arn]
  }
}

data "aws_iam_policy_document" "lambda_allow_logging" {
  statement {
    effect = "Allow"
    sid    = "AllowPublishMessageToCloudWatch"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${var.project_name}-aws-reports-notification-group:*"]
  }
}
