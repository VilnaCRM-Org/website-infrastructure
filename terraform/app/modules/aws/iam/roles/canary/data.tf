data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}


data "aws_iam_policy_document" "canary-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "canary-policy" {
  statement {
    sid    = "CanaryS3ObjectPermission"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets"
    ]
    resources = [
      var.canaries_reports_bucket_arn,
      "${var.canaries_reports_bucket_arn}/*"
    ]
  }

  statement {
    sid    = "CanaryS3ListPermission"
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets"
    ]
    resources = [
      "arn:aws:s3:::*"
    ]
  }

  statement {
    sid    = "CanaryXRAYPermission"
    effect = "Allow"
    actions = [
      "xray:PutTraceSegments"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "CanaryCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
    ]
  }

  statement {
    sid    = "CanaryCloudWatchAlarm"
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "StringEquals"
      values   = ["CloudWatchSynthetics"]
      variable = "cloudwatch:namespace"
    }
  }
}
