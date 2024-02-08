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

    environment_variable {
      name  = "TS_ENV"
      value = var.environment
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }
    environment_variable {
      name  = "TF_VAR_slack_workspace_id"
      value = var.slack_workspace_id
    }
    environment_variable {
      name  = "TF_VAR_slack_channel_id"
      value = var.slack_channel_id
    }
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }
  source {
    type            = var.build_project_source
    buildspec       = "./${local.path_to_buildspec}/buildspec_${var.build_projects[count.index]}.yml"
    git_clone_depth = 1
  }
}