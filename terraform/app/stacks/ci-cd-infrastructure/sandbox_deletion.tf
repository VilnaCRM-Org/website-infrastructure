resource "aws_codebuild_project" "sandbox_deletion" {
  name          = "sandbox-deletion"
  service_role  = aws_iam_role.codebuild_role_sandbox.arn

  source {
    type      = "GITHUB"
    location  = "https://github.com/VilnaCRM-Org/website-infrastructure"
    buildspec = "./aws/buildspecs/sandbox/delete.yml"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:5.0"
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
        Branch     = "3-implement-sandbox-infrastructure"
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

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess",
    "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
  ]
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
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  ]
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "codepipeline-artifacts-bucket-deletion"
}