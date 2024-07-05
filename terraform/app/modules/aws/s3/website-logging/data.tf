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

data "aws_iam_policy_document" "s3_kms_key_policy_doc" {
  statement {
    sid     = "EnableRootAccessAndPreventPermissionDelegationForLambdaKMSKey"
    effect  = "Allow"
    actions = ["kms:*"]
    #checkov:skip=CKV_AWS_356:Without this statement, KMS key cannot be managed by root
    resources = ["${aws_kms_key.s3_kms_key.arn}"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }

  statement {
    sid       = "AllowAccessForKeyAdministrators"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["${aws_kms_key.s3_kms_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

  }
  statement {
    sid    = "AllowUseOfTheKeyToCloudfront"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = ["${aws_kms_key.s3_kms_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }

  statement {
    sid    = "AllowUseOfTheKey"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = ["${aws_kms_key.s3_kms_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "replication_s3_kms_key_policy_doc" {
  statement {
    sid     = "EnableRootAccessAndPreventPermissionDelegationForLambdaKMSKey"
    effect  = "Allow"
    actions = ["kms:*"]
    #checkov:skip=CKV_AWS_356:Without this statement, KMS key cannot be managed by root
    resources = ["${aws_kms_key.replication_s3_kms_key.arn}"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }

  statement {
    sid       = "AllowAccessForKeyAdministrators"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["${aws_kms_key.replication_s3_kms_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

  }
  statement {
    sid    = "AllowUseOfTheKeyToCloudfront"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = ["${aws_kms_key.replication_s3_kms_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }

  statement {
    sid    = "AllowUseOfTheKey"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = ["${aws_kms_key.replication_s3_kms_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
  }
}