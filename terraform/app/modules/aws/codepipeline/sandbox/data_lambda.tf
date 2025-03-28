data "aws_iam_policy_document" "sandbox_cleanup_function_policy" {
  statement {
    sid    = "AllowS3BucketManagement"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:DeleteBucket",
      "s3:DeleteObject",
      "s3:ListBucketVersions",
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::sandbox-*",
      "arn:aws:s3:::sandbox-*/*"
    ]
  }

  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.id}:${local.account_id}:log-group:/aws/lambda/sandbox-cleanup-lambda:*"
    ]
  }

  statement {
    sid    = "AllowEventBridgeRuleManagement"
    effect = "Allow"
    actions = [
      "events:RemoveTargets",
      "events:DeleteRule",
      "events:ListTargetsByRule"
    ]
    resources = [
      "arn:aws:events:${data.aws_region.current.id}:${local.account_id}:rule/sandbox-cleanup-*"
    ]
  }

  statement {
    sid    = "AllowEventBridgeInvokeFunction"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
    ]
    resources = [
      "arn:aws:lambda:${data.aws_region.current.id}:${local.account_id}:function:sandbox-cleanup-lambda"
    ]
  }

  statement {
    sid    = "AllowEventBridgeListRules"
    effect = "Allow"
    actions = [
      "events:ListRules"
    ]
    resources = [
      "arn:aws:events:${data.aws_region.current.id}:${local.account_id}:rule/*"
    ]
  }

  depends_on = [aws_iam_role.sandbox_cleanup_function_role]
}
