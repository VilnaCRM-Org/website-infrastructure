data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_iam_policy_document" "bucket_policy_doc" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.logging_bucket.arn,
      "${aws_s3_bucket.logging_bucket.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      values   = ["${var.aws_cloudfront_distribution_arn}"]
      variable = "aws:SourceArn"
    }
  }

  statement {
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.logging_bucket.arn,
      "${aws_s3_bucket.logging_bucket.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      values   = ["${var.aws_s3_bucket_this_arn}"]
      variable = "aws:SourceArn"
    }
  }
}

data "aws_iam_policy_document" "replication_bucket_policy_doc" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.replication_logging_bucket.arn,
      "${aws_s3_bucket.replication_logging_bucket.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      values   = ["${var.aws_cloudfront_distribution_arn}"]
      variable = "aws:SourceArn"
    }
  }

  statement {
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.replication_logging_bucket.arn,
      "${aws_s3_bucket.replication_logging_bucket.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      values   = ["${var.aws_replication_s3_bucket_arn}"]
      variable = "aws:SourceArn"
    }
  }
}