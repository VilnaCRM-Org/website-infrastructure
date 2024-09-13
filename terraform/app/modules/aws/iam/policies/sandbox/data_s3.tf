data "aws_iam_policy_document" "s3_policy_doc" {
  statement {
    sid    = "S3PolicyArtifactBucket"
    effect = "Allow"
    actions = [
      "s3:CreateBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketLogging",
      "s3:GetBucketTagging",
      "s3:GetLifecycleConfiguration",
      "s3:PutBucketLogging",
      "s3:GetBucketWebsite",
      "s3:PutBucketWebsite",
      "s3:PutBucketTagging",
      "s3:PutLifecycleConfiguration",
      "s3:GetBucketCORS"
    ]
    resources = [
      "arn:aws:s3:::${var.project_name}-*",
    ]
  }
} 