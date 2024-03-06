data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_iam_policy_document" "this" {
  statement {
    sid       = "AllowCloudFrontServicePrincipal"
    effect  = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [var.aws_cloudfront_distribution_arn]
    }

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "sns_bucket_topic_doc" {
  statement {
    sid = "AllowSNSServicePrincipal"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    effect  = "Allow"
    actions = ["sns:Publish"]
    resources = ["${aws_sns_topic.bucket_notifications.arn}"]

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = ["${aws_s3_bucket.this.arn}"]
    }
  }
}
data "aws_iam_policy_document" "bucket_sns_kms_key_policy_doc" {
  statement {
    sid     = "EnableRootAccessAndPreventPermissionDelegationForS3BucketSNSKMSKey"
    effect  = "Allow"
    actions = ["kms:*"]
    #checkov:skip=CKV_AWS_356:Without this statement, KMS key cannot be managed by root
    resources = ["${aws_kms_key.bucket_sns_encryption_key.arn}"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }
  statement {
    sid       = "AllowAccessForKeyAdministratorsForS3BucketSNSKMSKey"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["${aws_kms_key.bucket_sns_encryption_key.arn}"]
  }
  statement {
    sid    = "AllowUseOfTheKeyForS3BucketSNSKMSKey"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = ["${aws_kms_key.bucket_sns_encryption_key.arn}"]

  }
  statement {
    sid    = "AllowUseOfTheKeyForSNSKMSKey"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey*",
      "kms:Decrypt"
    ]

    resources = ["${aws_kms_key.bucket_sns_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "replication" {
  statement {
    sid       = "AllowCloudFrontServicePrincipal"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.replication_bucket.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [var.aws_cloudfront_distribution_arn]
    }
  }
  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [aws_s3_bucket.this.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

    resources = ["${aws_s3_bucket.this.arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = ["${aws_s3_bucket.replication_bucket.arn}/*"]
  }
}