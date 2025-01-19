data "aws_iam_policy_document" "s3_policy_doc" {
  statement {
    sid    = "S3PolicyArtifactBucket"
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
      "s3:PutBucketVersioning",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutBucketLogging",
      "s3:PutLifecycleConfiguration",
      "s3:GetBucketPublicAccessBlock",
      "s3:PutEncryptionConfiguration",
      "s3:DeleteBucketPolicy",
      "s3:DeleteBucket",
      "s3:ListBucketVersions",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion"
    ]
    resources = [
      "arn:aws:s3:::${var.ci_cd_project_name}-logging-bucket",
      "arn:aws:s3:::${var.ci_cd_project_name}-logging-bucket/*",
      "arn:aws:s3:::${var.website_project_name}-codepipeline-artifacts-bucket",
      "arn:aws:s3:::${var.website_project_name}-codepipeline-artifacts-bucket/*",
      "arn:aws:s3:::${var.ci_cd_project_name}-codepipeline-artifacts-bucket",
      "arn:aws:s3:::${var.ci_cd_project_name}-codepipeline-artifacts-bucket/*",
      "arn:aws:s3:::${var.ci_cd_website_project_name}-codepipeline-artifacts-bucket",
      "arn:aws:s3:::${var.ci_cd_website_project_name}-codepipeline-artifacts-bucket/*",
      "arn:aws:s3:::${var.ci_cd_website_project_name}-lhci-reports-bucket",
      "arn:aws:s3:::${var.ci_cd_website_project_name}-lhci-reports-bucket/*",
      "arn:aws:s3:::${var.ci_cd_website_project_name}-test-reports-bucket",
      "arn:aws:s3:::${var.ci_cd_website_project_name}-test-reports-bucket/*",
      "arn:aws:s3:::${var.project_name}-access-logs-test",
      "arn:aws:s3:::${var.project_name}-access-logs-test/*",
      "arn:aws:s3:::sandbox-${var.environment}-codepipeline-artifacts-bucket",
      "arn:aws:s3:::sandbox-${var.environment}-codepipeline-artifacts-bucket/*",
      "arn:aws:s3:::${var.project_name}-codepipeline-artifacts-${var.environment}",
      "arn:aws:s3:::${var.project_name}-codepipeline-artifacts-${var.environment}/*",
      "arn:aws:s3:::${var.project_name}-codebuild-logs-test",
      "arn:aws:s3:::${var.project_name}-codebuild-logs-test/*",
    ]
  }
  statement {
    sid    = "S3PolicyReportsBuckets"
    effect = "Allow"
    actions = [
      "s3:GetBucketOwnershipControls",
      "s3:GetBucketLocation",
      "s3:PutBucketOwnershipControls"
    ]
    resources = [

      "arn:aws:s3:::${var.ci_cd_website_project_name}-lhci-reports-bucket",
      "arn:aws:s3:::${var.ci_cd_website_project_name}-lhci-reports-bucket/*",
      "arn:aws:s3:::${var.ci_cd_website_project_name}-test-reports-bucket",
      "arn:aws:s3:::${var.ci_cd_website_project_name}-test-reports-bucket/*"
    ]
  }
} 