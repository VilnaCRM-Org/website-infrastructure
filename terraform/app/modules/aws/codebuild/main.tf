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
      name  = "SESSION_NAME"
      value = "${var.project_name}-${var.build_projects[count.index]}-session"
    }

    dynamic "environment_variable" {
      for_each = var.environment_variables
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
    buildspec       = "./aws/buildspecs/${var.stack}/buildspec_${var.build_projects[count.index]}.yml"
    git_clone_depth = 1
  }
}