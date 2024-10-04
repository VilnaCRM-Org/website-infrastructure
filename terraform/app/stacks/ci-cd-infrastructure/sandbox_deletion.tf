resource "aws_iam_role_policy" "codepipeline_restricted_access" {
  name = "codepipeline-restricted-access-policy"
  role = aws_iam_role.codepipeline_role_sandbox.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codepipeline:StartPipelineExecution",
          "codepipeline:PutJobSuccessResult",
          "codepipeline:PutJobFailureResult",
          "codepipeline:GetPipelineState",
          "codepipeline:GetPipelineExecution",
          "codepipeline:GetPipeline",
          "codepipeline:ListPipelineExecutions",
          "codepipeline:ListPipelines"
        ]
        Resource = [
          "${aws_codepipeline.sandbox_pipeline.arn}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds",
          "codebuild:ListBuilds",
          "codebuild:ListProjects",
          "codebuild:BatchGetProjects"
        ]
        Resource = [
          "${aws_codebuild_project.sandbox_deletion.arn}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.codepipeline_bucket.arn}/*",
          "${aws_s3_bucket.codepipeline_bucket.arn}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:EnableAlarmActions",
          "cloudwatch:DisableAlarmActions"
        ]
        Resource = [
          "${aws_codepipeline.sandbox_pipeline.arn}",
          "${aws_codebuild_project.sandbox_deletion.arn}"
        ]
      }
    ]
  })
}

resource "aws_codebuild_project" "sandbox_deletion" {
  name         = "sandbox-deletion"
  service_role = aws_iam_role.codebuild_role_sandbox.arn

  source {
    type      = "GITHUB"
    location  = "https://github.com/${var.source_repo_owner}/${var.source_repo_name}"
    buildspec = var.buildspec_path
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"
  }

  logs_config {
    s3_logs {
      status   = "ENABLED"
      location = aws_s3_bucket.codebuild_logs_bucket.arn
    }
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }
}

resource "aws_codepipeline" "sandbox_pipeline" {
  name     = "sandbox-pipeline-deletion"
  role_arn = aws_iam_role.codepipeline_role_sandbox.arn
  #checkov:skip=CKV_AWS_219:CodePipeline Artifact store does not need a KMS CMK
  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.codepipeline_bucket.bucket
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = var.source_repo_owner
        Repo       = var.source_repo_name
        Branch     = var.source_repo_branch
        OAuthToken = var.GITHUB_TOKEN
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.sandbox_deletion.name
      }
    }
  }
}

resource "aws_iam_role" "codepipeline_role_sandbox" {
  name = "codepipeline-role-sandbox-deletion"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role" "codebuild_role_sandbox" {
  name = "codebuild-role-sandbox-deletion"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "codebuild_s3_access_policy" {
  name        = "codebuild-s3-access-policy-sandbox"
  description = "Policy to allow CodeBuild to access S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.codepipeline_bucket.arn}",
          "${aws_s3_bucket.codepipeline_bucket.arn}/*",
          "${aws_s3_bucket.codebuild_logs_bucket.arn}",
          "${aws_s3_bucket.codebuild_logs_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_s3_access_policy_attachment" {
  role       = aws_iam_role.codebuild_role_sandbox.id
  policy_arn = aws_iam_policy.codebuild_s3_access_policy.arn
}

resource "aws_iam_role_policy" "codebuild_cloudwatch_logs_access" {
  name = "codebuild-cloudwatch-logs-access-policy-sandbox"
  role = aws_iam_role.codebuild_role_sandbox.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          "arn:aws:logs:${var.region}:${local.account_id}:log-group:/aws/codebuild/${aws_codebuild_project.sandbox_deletion.name}",
          "arn:aws:logs:${var.region}:${local.account_id}:log-group:/aws/codebuild/${aws_codebuild_project.sandbox_deletion.name}:*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket" "access_logs_bucket" {
  #checkov:skip=CKV_AWS_145:The KMS encryption of access logs bucket is not needed
  #checkov:skip=CKV2_AWS_62:The event notifications of access logs bucket is not needed
  #checkov:skip=CKV_AWS_144:The S3 bucket cross-region replication is not needed
  bucket = local.sandbox_access_logs_bucket_name

  tags = {
    Name = "sandbox-deletion-access-logs-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "access_logs_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.access_logs_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "access_logs_bucket_lifecycle" {
  bucket = aws_s3_bucket.access_logs_bucket.id

  rule {
    id     = "log-expiration"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_versioning" "access_logs_bucket_versioning" {
  bucket = aws_s3_bucket.access_logs_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  #checkov:skip=CKV2_AWS_62:The event notifications of access logs bucket is not needed
  #checkov:skip=CKV_AWS_144:The S3 bucket cross-region replication is not needed
  bucket = local.codepipeline_artifacts_bucket_name

  tags = {
    Name = "codepipeline-deletion-artifacts-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "codepipeline_bucket_public_access_block" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "codepipeline_bucket_lifecycle" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  rule {
    id     = "lifecycle-30-days-glacier"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket_logging" "codepipeline_bucket_logging" {
  bucket        = aws_s3_bucket.codepipeline_bucket.id
  target_bucket = aws_s3_bucket.access_logs_bucket.bucket
  target_prefix = "log/"
}

resource "aws_s3_bucket_versioning" "codepipeline_bucket_versioning" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "codebuild_logs_bucket" {
  bucket = "${var.project_name}-codebuild-logs-bucket"
  #checkov:skip=CKV_AWS_144:The S3 bucket cross-region replication is not needed
  #checkov:skip=CKV2_AWS_62:The event notifications of access logs bucket is not needed
  #checkov:skip=CKV_AWS_145:The KMS encryption of access logs bucket is not needed
  #checkov:skip=CKV_AWS_18:The access logging of this bucket is not needed

  tags = {
    Name        = "${var.project_name}-codebuild-logs-bucket"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_s3_bucket_public_access_block" "codebuild_logs_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.codebuild_logs_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "codebuild_logs_bucket_versioning" {
  bucket = aws_s3_bucket.codebuild_logs_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "codebuild_logs_bucket_lifecycle" {
  bucket = aws_s3_bucket.codebuild_logs_bucket.id

  rule {
    id     = "AbortIncompleteUploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  rule {
    id     = "ExpireOldLogs"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}

locals {
  sandbox_access_logs_bucket_name    = "${var.project_name}-sandbox-access-logs-${var.environment}"
  codepipeline_artifacts_bucket_name = "${var.project_name}-codepipeline-artifacts-${var.environment}"
}