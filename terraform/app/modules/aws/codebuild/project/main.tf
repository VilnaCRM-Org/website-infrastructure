resource "aws_codebuild_project" "terraform_codebuild_project" {

  name         = var.project_name
  service_role = var.role_arn
  tags         = var.tags

  artifacts {
    type                = "NO_ARTIFACTS"
    encryption_disabled = true
  }

  environment {
    compute_type                = var.build_configuration.builder_compute_type
    image                       = var.build_configuration.builder_image
    type                        = var.build_configuration.builder_type
    privileged_mode             = var.build_configuration.privileged_mode
    image_pull_credentials_type = var.build_configuration.builder_image_pull_credentials_type

    environment_variable {
      name  = "SESSION_NAME"
      value = "${var.project_name}-session"
    }

    dynamic "environment_variable" {
      for_each = var.env_variables
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }

  }

  source {
    type            = var.source_configuration.type
    buildspec       = var.source_configuration.buildspec
    location        = var.source_configuration.location
    git_clone_depth = var.source_configuration.depth
  }

  source_version = var.source_configuration.version


  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }
}