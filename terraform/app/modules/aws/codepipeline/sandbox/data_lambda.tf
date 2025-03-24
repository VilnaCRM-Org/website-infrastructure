resource "aws_iam_role" "lambda_cleanup_function_role" {
  name = "s3-cleanup-function-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "s3_cleanup_function_policy" {
  name        = "s3-cleanup-function-policy"
  description = "Allows Lambda to manage S3 buckets and objects"

  policy = data.aws_iam_policy_document.s3_cleanup_function_policy.json
}

data "aws_iam_policy_document" "s3_cleanup_function_policy" {
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
      "arn:aws:logs:*:*:*"
    ]
  }

  statement {
    sid    = "AllowEventBridgeRuleManagement"
    effect = "Allow"
    actions = [
      "events:RemoveTargets",
      "events:DeleteRule",
      "events:ListRules"
    ]
    resources = [
      "arn:aws:events:${data.aws_region.current.id}:${local.account_id}:rule/s3-cleanup-*"
    ]
  }

  statement {
    sid    = "AllowEventBridgeInvokeFunction"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
    ]
    resources = [
      "arn:aws:lambda:${data.aws_region.current.id}:${local.account_id}:function:s3-cleanup-lambda"
    ]
  }

  depends_on = [aws_iam_role.lambda_cleanup_function_role]
}

resource "aws_iam_role_policy_attachment" "lambda_s3_cleanup_attach" {
  role       = aws_iam_role.lambda_cleanup_function_role.name
  policy_arn = aws_iam_policy.s3_cleanup_function_policy.arn
}