resource "aws_codebuild_project" "sandbox_deletion" {
  name         = "${var.project_name}-deletion"
  service_role = var.codebuild_role_arn

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

  artifacts {
    type = "NO_ARTIFACTS"
  }

  logs_config {
    cloudwatch_logs {
    status              = "ENABLED"
    group_name          = "/aws/codebuild/${var.project_name}-deletion"
    stream_name         = "${var.project_name}-deletion-log-stream"
  }

    s3_logs {
      status   = "ENABLED"
      location = var.logs_bucket_name
    }
  }

}