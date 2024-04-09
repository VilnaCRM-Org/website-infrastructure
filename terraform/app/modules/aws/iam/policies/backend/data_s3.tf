
data "aws_iam_policy_document" "s3_policy_doc" {
  statement {
    sid    = "ReadOnlyS3Policy"
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:ListMultiRegionAccessPoints",
      "s3:ListTagsForResource",
      "s3:GetBucketLocation",
      "s3:GetBucketCORS",
      "s3:GetBucketAcl",
      "s3:GetBucketLogging",
      "s3:GetBucketNotification",
      "s3:GetBucketObjectLockConfiguration",
      "s3:GetBucketTagging",
      "s3:GetBucketVersioning",
      "s3:GetBucketWebsite",
      "s3:GetMetricsConfiguration",
      "s3:GetObject",
      "s3:GetObjectAttributes",
      "s3:GetObjectLegalHold",
      "s3:GetObjectRetention",
      "s3:GetObjectTagging",
      "s3:GetObjectTorrent",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionAttributes",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectVersionTorrent",
    ]
    resources = [
      "arn:aws:s3:::*"
    ]
  }
}

