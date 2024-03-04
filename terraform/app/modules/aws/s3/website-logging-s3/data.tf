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
      "s3:Get*",
      "s3:List*",
      "s3:ReplicateObject",
      "s3:PutObject",
      "s3:RestoreObject",
      "s3:PutObjectVersionTagging",
      "s3:PutObjectTagging",
      "s3:PutObjectAcl"
    ]

    resources = [
      aws_s3_bucket.logging_bucket.arn,
      "${aws_s3_bucket.logging_bucket.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      values   = ["${var.aws_cloudfront_distribution_arn}"]
      variable = "aws:SourceAccount"
    }
  }

  statement {
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:ReplicateObject",
      "s3:PutObject",
      "s3:RestoreObject",
      "s3:PutObjectVersionTagging",
      "s3:PutObjectTagging",
      "s3:PutObjectAcl"
    ]

    resources = [
      aws_s3_bucket.logging_bucket.arn,
      "${aws_s3_bucket.logging_bucket.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      values   = ["${var.aws_s3_bucket_this_arn}"]
      variable = "aws:SourceAccount"
    }
  }
}