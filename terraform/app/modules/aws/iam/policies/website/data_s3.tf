data "aws_iam_policy_document" "s3_policy_doc" {
  statement {
    sid    = "S3PolicyAllBuckets"
    effect = "Allow"
    actions = [
      "s3:CreateBucket",
      "s3:ListBucket",
      "s3:GetBucketTagging",
      "s3:PutBucketTagging",
      "s3:PutBucketPolicy",
      "s3:GetBucketPolicy",
      "s3:GetBucketAcl",
      "s3:GetBucketCORS",
      "s3:GetBucketWebsite",
      "s3:GetBucketVersioning",
      "s3:GetAccelerateConfiguration",
      "s3:GetBucketRequestPayment",
      "s3:GetBucketLogging",
      "s3:GetLifecycleConfiguration",
      "s3:GetReplicationConfiguration",
      "s3:GetEncryptionConfiguration",
      "s3:GetBucketObjectLockConfiguration",
      "s3:GetBucketOwnershipControls",
      "s3:PutBucketVersioning",
      "s3:PutObject",
      "s3:PutBucketAcl",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutBucketLogging",
      "s3:GetBucketPublicAccessBlock",
      "s3:PutEncryptionConfiguration",
      "s3:PutLifecycleConfiguration",
      "s3:PutBucketOwnershipControls",
      "s3:DeleteBucketPolicy",
      "s3:DeleteBucket",
      "s3:ListBucketVersions",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion"
    ]
    resources = [
      "arn:aws:s3:::${var.domain_name}",
      "arn:aws:s3:::${var.domain_name}/*",
      "arn:aws:s3:::staging.${var.domain_name}",
      "arn:aws:s3:::staging.${var.domain_name}/*",
      "arn:aws:s3:::${var.domain_name}-replication",
      "arn:aws:s3:::${var.domain_name}-replication/*",
      "arn:aws:s3:::staging.${var.domain_name}-replication",
      "arn:aws:s3:::staging.${var.domain_name}-replication/*",
      "arn:aws:s3:::${var.project_name}-logging-bucket",
      "arn:aws:s3:::${var.project_name}-logging-bucket/*",
      "arn:aws:s3:::${var.project_name}-replication-logging-bucket",
      "arn:aws:s3:::${var.project_name}-replication-logging-bucket/*",
    ]
  }
  statement {
    sid    = "S3PolicyContentBucket"
    effect = "Allow"
    actions = [
      "s3:GetBucketNotification",
      "s3:PutBucketNotification",
      "s3:PutReplicationConfiguration"
    ]
    resources = [
      "arn:aws:s3:::${var.domain_name}",
      "arn:aws:s3:::${var.domain_name}/*",
      "arn:aws:s3:::staging.${var.domain_name}",
      "arn:aws:s3:::staging.${var.domain_name}/*",
    ]
  }
  statement {
    sid    = "S3PolicyReplicationBucket"
    effect = "Allow"
    actions = [
      "s3:GetBucketOwnershipControls",
      "s3:PutBucketOwnershipControls"
    ]
    resources = [
      "arn:aws:s3:::${var.project_name}-logging-bucket",
      "arn:aws:s3:::${var.project_name}-logging-bucket/*",
    ]
  }
  statement {
    sid    = "S3CanariesBucket"
    effect = "Allow"
    actions = [
      "s3:*",
    ]
    resources = [
      "arn:aws:s3:::${var.project_name}-canaries-reports-bucket",
      "arn:aws:s3:::${var.project_name}-canaries-reports-bucket/*",
    ]
  }
  statement {
    sid    = "S3LibraryBucket"
    effect = "Allow"
    actions = [
      "s3:GetObjectVersion"
    ]
    resources = [
      "arn:aws:s3:::aws-synthetics-library-*"
    ]
  }
} 