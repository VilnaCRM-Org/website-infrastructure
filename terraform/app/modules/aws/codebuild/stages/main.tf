data "aws_secretsmanager_secret" "github_token" {
  name = var.github_token_arn
}

data "aws_secretsmanager_secret_version" "github_token" {
  secret_id     = data.aws_secretsmanager_secret.github_token.name
  version_stage = "AWSCURRENT"
}

resource "aws_codebuild_project" "terraform_codebuild_project" {
  # checkov:skip=CKV_AWS_147: Codebuild project has encryption by default
  for_each = var.build_projects

  name         = "${var.project_name}-${replace(each.key, "_", "-")}"
  service_role = var.role_arn
  tags         = var.tags

  artifacts {
    type      = each.value.build_project_source
    packaging = "NONE"
  }
  environment {
    compute_type                = each.value.builder_compute_type
    image                       = each.value.builder_image
    type                        = each.value.builder_type
    privileged_mode             = each.value.privileged_mode
    image_pull_credentials_type = each.value.builder_image_pull_credentials_type

    environment_variable {
      name  = "SESSION_NAME"
      value = "${var.project_name}-${each.key}-session"
    }

    environment_variable {
      name  = "GITHUB_TOKEN"
      value = jsondecode(data.aws_secretsmanager_secret_version.github_token.secret_string)["token"]
      type  = "PLAINTEXT"
    }

    dynamic "environment_variable" {
      for_each = each.value.env_variables
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
    type            = each.value.build_project_source
    buildspec       = each.value.buildspec
    git_clone_depth = 1
  }
  build_batch_config {
    service_role = var.role_arn
  }
}