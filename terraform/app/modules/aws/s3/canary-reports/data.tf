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

data "aws_iam_policy_document" "canaries_reports_bucket_policy_doc" {
  statement {
    sid    = "Permissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["${local.account_id}"]
    }

    actions   = ["s3:*"]
    resources = ["${aws_s3_bucket.canaries_reports_bucket.arn}/*"]
  }
  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["s3:*"]
    resources = [aws_s3_bucket.canaries_reports_bucket.arn,
    "${aws_s3_bucket.canaries_reports_bucket.arn}/*"]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}