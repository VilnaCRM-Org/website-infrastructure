resource "aws_codebuild_project" "terraform_codebuild_project" {

  name           = var.project_name
  service_role   = var.role_arn
  encryption_key = var.kms_key_arn
  tags           = var.tags

  artifacts {
    type = "NO_ARTIFACTS"
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
    type            = "GITHUB"
    buildspec       = "./aws/buildspecs/website/down.yml"
    location        = "https://github.com/VilnaCRM-Org/website-infrastructure.git"
    git_clone_depth = 1
  }

  source_version = "2-set-up-the-frontend-production-infrastructure"


  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }
}