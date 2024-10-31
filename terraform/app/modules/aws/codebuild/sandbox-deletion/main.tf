resource "aws_codebuild_project" "sandbox_deletion" {
  name         = "${var.project_name}-deletion"
  service_role = var.codebuild_role_arn

  source {
    type            = "GITHUB_ENTERPRISE"
    location        = "${var.source_repo_owner}/${var.source_repo_name}"
    buildspec       = var.buildspec_path
    git_clone_depth = 1
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "PROJECT_NAME"
      value = var.project_name
    }
    environment_variable {
      name  = "BRANCH_NAME"
      value = var.BRANCH_NAME
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  logs_config {
    cloudwatch_logs {
      status      = "ENABLED"
      group_name  = "/aws/codebuild/${var.project_name}-deletion"
      stream_name = "${var.project_name}-deletion-log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = var.logs_bucket_arn
    }
  }

}