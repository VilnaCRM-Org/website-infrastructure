data "aws_iam_policy_document" "sns_bucket_topic_doc" {
  statement {
    sid = "AllowSNSServicePrincipal"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = ["${aws_sns_topic.bucket_notifications.arn}"]
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

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
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

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
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
      type        = "AWS"
      identifiers = ["${aws_iam_role.iam_for_lambda.arn}"]
    }
  }
}