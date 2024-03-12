resource "aws_codebuild_project" "terraform_codebuild_project" {

  count = length(var.build_projects)

  name           = "${var.project_name}-${var.build_projects[count.index]}"
  service_role   = var.role_arn
  encryption_key = var.kms_key_arn
  tags           = var.tags

  artifacts {
    type = var.build_project_source
  }
  environment {
    compute_type                = var.builder_compute_type
    image                       = var.builder_image
    type                        = var.builder_type
    privileged_mode             = false
    image_pull_credentials_type = var.builder_image_pull_credentials_type

    dynamic "environment_variable" {
      for_each = {
        "TS_ENV"                               = var.environment,
        "AWS_DEFAULT_REGION"                   = var.region,
        "SECRET_NAME"                          = var.secretsmanager_secret_name,
        "TF_VAR_SLACK_WORKSPACE_ID"            = var.SLACK_WORKSPACE_ID,
        "TF_VAR_CODEPIPELINE_SLACK_CHANNEL_ID" = var.CODEPIPELINE_SLACK_CHANNEL_ID,
        "TF_VAR_ALERTS_SLACK_CHANNEL_ID"       = var.ALERTS_SLACK_CHANNEL_ID,
        "WEBSITE_URL"                          = var.website_url,
        "PYTHON_VERSION"                       = var.python_version,
        "RUBY_VERSION"                         = var.ruby_version,
        "SCRIPT_DIR"                           = var.script_dir,
      }
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }

  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }
  source {
    type            = var.build_project_source
    buildspec       = "./aws/buildspecs/buildspec_${var.build_projects[count.index]}.yml"
    git_clone_depth = 1
  }
}