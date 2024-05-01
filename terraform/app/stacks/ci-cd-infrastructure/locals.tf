locals {
  account_id = data.aws_caller_identity.current.account_id

  ubuntu_based_build = {
    builder_compute_type                = var.default_builder_compute_type
    builder_image                       = var.ubuntu_builder_image
    builder_type                        = var.default_builder_type
    builder_image_pull_credentials_type = var.default_builder_image_pull_credentials_type
    build_project_source                = var.default_build_project_source
    privileged_mode                     = false
  }

  amazonlinux2_based_build = {
    builder_compute_type                = var.default_builder_compute_type
    builder_image                       = var.amazonlinux2_builder_image
    builder_type                        = var.default_builder_type
    builder_image_pull_credentials_type = var.default_builder_image_pull_credentials_type
    build_project_source                = var.default_build_project_source
    privileged_mode                     = false
  }
}

locals {
  website_infra_build_projects = {
    validate = merge(local.amazonlinux2_based_build,
      { env_variables = {
        "ROLE_ARN"                       = module.website_infra_codepipeline_iam_role.terraform_role_arn,
        "TF_VAR_SLACK_WORKSPACE_ID"      = var.SLACK_WORKSPACE_ID,
        "TF_VAR_ALERTS_SLACK_CHANNEL_ID" = var.ALERTS_SLACK_CHANNEL_ID,
        "TS_ENV"                         = var.environment,
        "AWS_DEFAULT_REGION"             = var.region,
        "PYTHON_VERSION"                 = var.python_version,
        "RUBY_VERSION"                   = var.ruby_version,
        "GOLANG_VERSION"                 = var.golang_version
        "SCRIPT_DIR"                     = var.script_dir,
        }
    })

    plan = merge(local.amazonlinux2_based_build,
      { env_variables = {
        "ROLE_ARN"                       = module.website_infra_codepipeline_iam_role.terraform_role_arn,
        "TF_VAR_SLACK_WORKSPACE_ID"      = var.SLACK_WORKSPACE_ID,
        "TF_VAR_ALERTS_SLACK_CHANNEL_ID" = var.ALERTS_SLACK_CHANNEL_ID,
        "TS_ENV"                         = var.environment,
        "AWS_DEFAULT_REGION"             = var.region,
        "PYTHON_VERSION"                 = var.python_version,
        "RUBY_VERSION"                   = var.ruby_version,
        "SCRIPT_DIR"                     = var.script_dir,
        }
    })

    up = merge(local.amazonlinux2_based_build,
      { env_variables = {
        "ROLE_ARN"                       = module.website_infra_codepipeline_iam_role.terraform_role_arn,
        "TF_VAR_SLACK_WORKSPACE_ID"      = var.SLACK_WORKSPACE_ID,
        "TF_VAR_ALERTS_SLACK_CHANNEL_ID" = var.ALERTS_SLACK_CHANNEL_ID,
        "TS_ENV"                         = var.environment,
        "AWS_DEFAULT_REGION"             = var.region,
        "PYTHON_VERSION"                 = var.python_version,
        "RUBY_VERSION"                   = var.ruby_version,
        "SCRIPT_DIR"                     = var.script_dir,
        }
    })

    deploy = merge(local.ubuntu_based_build,
      { env_variables = {
        "NODEJS_VERSION"                = var.nodejs_version,
        "BUCKET_NAME"                   = var.bucket_name,
        "WEBSITE_GIT_REPOSITORY_BRANCH" = var.website_repo_branch,
        "WEBSITE_GIT_REPOSITORY_LINK"   = "https://github.com/${var.source_repo_owner}/${var.website_content_repo_name}",
        }
    })

    healthcheck = merge(local.amazonlinux2_based_build,
      { env_variables = {
        "WEBSITE_URL" = var.website_url,
        }
    })

    down = merge(local.amazonlinux2_based_build,
      { env_variables = {
        "ROLE_ARN"                       = module.website_infra_codepipeline_iam_role.terraform_role_arn,
        "TF_VAR_SLACK_WORKSPACE_ID"      = var.SLACK_WORKSPACE_ID,
        "TF_VAR_ALERTS_SLACK_CHANNEL_ID" = var.ALERTS_SLACK_CHANNEL_ID,
        "TS_ENV"                         = var.environment,
        "AWS_DEFAULT_REGION"             = var.region,
        "PYTHON_VERSION"                 = var.python_version,
        "RUBY_VERSION"                   = var.ruby_version,
        "SCRIPT_DIR"                     = var.script_dir,
        }
    })
  }

  ci_cd_infra_build_projects = {
    validate = merge(local.amazonlinux2_based_build,
      { env_variables = {
        "ROLE_ARN"                             = module.ci_cd_infra_codepipeline_iam_role.terraform_role_arn,
        "TF_VAR_SLACK_WORKSPACE_ID"            = var.SLACK_WORKSPACE_ID,
        "TF_VAR_CODEPIPELINE_SLACK_CHANNEL_ID" = var.CODEPIPELINE_SLACK_CHANNEL_ID,
        "TF_VAR_REPORT_SLACK_CHANNEL_ID"       = var.REPORT_SLACK_CHANNEL_ID,
        "TF_VAR_ALERTS_SLACK_CHANNEL_ID"       = var.ALERTS_SLACK_CHANNEL_ID,
        "TS_ENV"                               = var.environment,
        "AWS_DEFAULT_REGION"                   = var.region,
        "PYTHON_VERSION"                       = var.python_version,
        "GOLANG_VERSION"                       = var.golang_version
        "RUBY_VERSION"                         = var.ruby_version,
        "SCRIPT_DIR"                           = var.script_dir,
        }
    })

    plan = merge(local.amazonlinux2_based_build,
      { env_variables = {
        "ROLE_ARN"                             = module.ci_cd_infra_codepipeline_iam_role.terraform_role_arn,
        "TF_VAR_SLACK_WORKSPACE_ID"            = var.SLACK_WORKSPACE_ID,
        "TF_VAR_CODEPIPELINE_SLACK_CHANNEL_ID" = var.CODEPIPELINE_SLACK_CHANNEL_ID,
        "TF_VAR_REPORT_SLACK_CHANNEL_ID"       = var.REPORT_SLACK_CHANNEL_ID,
        "TF_VAR_ALERTS_SLACK_CHANNEL_ID"       = var.ALERTS_SLACK_CHANNEL_ID,
        "TS_ENV"                               = var.environment,
        "AWS_DEFAULT_REGION"                   = var.region,
        "PYTHON_VERSION"                       = var.python_version,
        "RUBY_VERSION"                         = var.ruby_version,
        "SCRIPT_DIR"                           = var.script_dir,
        }
    })

    up = merge(local.amazonlinux2_based_build,
      { env_variables = {
        "ROLE_ARN"                       = module.ci_cd_infra_codepipeline_iam_role.terraform_role_arn,
        "TF_VAR_SLACK_WORKSPACE_ID"      = var.SLACK_WORKSPACE_ID,
        "TF_VAR_REPORT_SLACK_CHANNEL_ID" = var.REPORT_SLACK_CHANNEL_ID,
        "TF_VAR_ALERTS_SLACK_CHANNEL_ID" = var.ALERTS_SLACK_CHANNEL_ID,
        "TS_ENV"                         = var.environment,
        "AWS_DEFAULT_REGION"             = var.region,
        "PYTHON_VERSION"                 = var.python_version,
        "RUBY_VERSION"                   = var.ruby_version,
        "SCRIPT_DIR"                     = var.script_dir,
        }
    })
  }

  ci_cd_website_build_projects = {

    lint = merge(local.ubuntu_based_build,
      { env_variables = {
        "NODEJS_VERSION"                = var.nodejs_version,
        "WEBSITE_GIT_REPOSITORY_BRANCH" = var.website_repo_branch,
        "WEBSITE_GIT_REPOSITORY_LINK"   = "https://github.com/${var.source_repo_owner}/${var.website_content_repo_name}"
        }
    })

    deploy = merge(local.ubuntu_based_build,
      { env_variables = {
        "NODEJS_VERSION"                = var.nodejs_version,
        "BUCKET_NAME"                   = var.bucket_name
        "WEBSITE_GIT_REPOSITORY_BRANCH" = var.website_repo_branch,
        "WEBSITE_GIT_REPOSITORY_LINK"   = "https://github.com/${var.source_repo_owner}/${var.website_content_repo_name}"
        }
    })

    test = merge(local.ubuntu_based_build,
      { env_variables = {
        "NODEJS_VERSION"                = var.nodejs_version,
        "PW_TEST_HTML_REPORT_OPEN"      = "never",
        "WEBSITE_URL"                   = var.website_url,
        "ENVIRONMENT"                   = var.environment,
        "ARTIFACTS_OUTPUT_DIR"          = "TestOutput",
        "ACCOUNT_ID"                    = local.account_id
        "SCRIPT_DIR"                    = var.script_dir,
        "TEST_REPORTS_BUCKET"           = module.test_reports_bucket.name
        "WEBSITE_GIT_REPOSITORY_BRANCH" = var.website_repo_branch,
        "WEBSITE_GIT_REPOSITORY_LINK"   = "https://github.com/${var.source_repo_owner}/${var.website_content_repo_name}"
        }
    })

    healthcheck = merge(local.amazonlinux2_based_build,
      { env_variables = {
        "WEBSITE_URL" = var.website_url
        }
    })

    lighthouse = merge(local.ubuntu_based_build,
      { env_variables = {
        "NODEJS_VERSION"                = var.nodejs_version,
        "WEBSITE_URL"                   = var.website_url,
        "ENVIRONMENT"                   = var.environment,
        "ARTIFACTS_OUTPUT_DIR"          = "LHCIOutput",
        "ACCOUNT_ID"                    = local.account_id
        "SCRIPT_DIR"                    = var.script_dir,
        "LHCI_REPORTS_BUCKET"           = module.lhci_reports_bucket.name
        "WEBSITE_GIT_REPOSITORY_BRANCH" = var.website_repo_branch,
        "WEBSITE_GIT_REPOSITORY_LINK"   = "https://github.com/${var.source_repo_owner}/${var.website_content_repo_name}"
        }
    })
  }
}

