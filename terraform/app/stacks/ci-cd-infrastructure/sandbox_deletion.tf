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
          "arn:aws:codepipeline:${var.region}:${local.account_id}:sandbox-pipeline-deletion",
          "arn:aws:codebuild:${var.region}:${local.account_id}:project/sandbox-deletion"
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
          "arn:aws:codepipeline:${var.region}:${local.account_id}:sandbox-pipeline-deletion",
          "arn:aws:codebuild:${var.region}:${local.account_id}:project/sandbox-deletion"
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
        Resource = "arn:aws:s3:::codepipeline-artifacts-bucket-deletion/*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:EnableAlarmActions",
          "cloudwatch:DisableAlarmActions"
        ]
        Resource = [
          "arn:aws:codepipeline:${var.region}:${local.account_id}:sandbox-pipeline-deletion",
          "arn:aws:codebuild:${var.region}:${local.account_id}:project/sandbox-deletion"
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
    location  = "https://github.com/VilnaCRM-Org/website-infrastructure"
    buildspec = var.buildspec_path
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }
}

resource "aws_codepipeline" "sandbox_pipeline" {
  name     = "sandbox-pipeline-deletion"
  role_arn = aws_iam_role.codepipeline_role_sandbox.arn

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
        Owner      = "VilnaCRM-Org"
        Repo       = "website-infrastructure"
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

resource "aws_iam_role_policy" "codepipeline_s3_access" {
  name = "codepipeline-s3-access-policy-sandbox"
  role = aws_iam_role.codepipeline_role_sandbox.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::codepipeline-artifacts-bucket-deletion",
          "arn:aws:s3:::codepipeline-artifacts-bucket-deletion/*"
        ]
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

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess"
  ]
}

resource "aws_iam_role_policy" "codebuild_logs_access" {
  name = "codebuild-logs-access-policy-sandbox"
  role = aws_iam_role.codebuild_role_sandbox.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents"
        ]
        Resource = [
          "arn:aws:logs:${var.region}:${local.account_id}:log-group:/aws/codebuild/sandbox-deletion*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "codepipeline-artifacts-bucket-deletion"
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
  target_bucket = "access-logs-bucket"
  target_prefix = "log/"
}

resource "aws_s3_bucket_versioning" "codepipeline_bucket_versioning" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}