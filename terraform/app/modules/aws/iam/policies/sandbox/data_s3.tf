data "aws_iam_policy_document" "s3_policy_doc" {
  statement {
    sid    = "S3PolicyArtifactBucket"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.project_name}-*",
    ]
  }
} 