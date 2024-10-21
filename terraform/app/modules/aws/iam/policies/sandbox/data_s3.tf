data "aws_iam_policy_document" "s3_policy_doc" {
  statement {
    sid    = "S3PolicyArtifactBucket"
    effect = "Allow"
    actions = [
      "s3:PutBucketAcl",
      "s3:PutBucketPolicy",
      "s3:PutBucketWebsite",
      "s3:PutObject",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutBucketOwnerShipControls",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:CreateBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.project_name}-*",
    ]
  }
} 