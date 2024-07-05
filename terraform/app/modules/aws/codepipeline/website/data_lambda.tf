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



data "aws_iam_policy_document" "lambda_kms_key_policy_doc" {
  statement {
    sid     = "EnableRootAccessAndPreventPermissionDelegationForLambdaKMSKey"
    effect  = "Allow"
    actions = ["kms:*"]
    #checkov:skip=CKV_AWS_356:Without this statement, KMS key cannot be managed by root
    resources = ["${aws_kms_key.lambda_encryption_key.arn}"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }

  statement {
    sid       = "AllowAccessForKeyAdministratorsForLambdaKMSKey"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["${aws_kms_key.lambda_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = [aws_lambda_function.func.arn]
    }
  }
  statement {
    sid    = "AllowUseOfTheKeyForLambdaKMSKey"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
    ]

    resources = ["${aws_kms_key.lambda_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = [aws_lambda_function.func.arn]
    }
  }
}