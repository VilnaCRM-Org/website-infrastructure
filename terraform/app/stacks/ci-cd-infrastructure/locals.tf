locals {
  account_id = data.aws_caller_identity.current.account_id
  alarm_name = "website-${var.region}-s3-objects-anomaly-detection"
  ubuntu_based_build = {
    builder_compute_type                = var.codebuild_environment.default_builder_compute_type
    builder_image                       = var.codebuild_environment.ubuntu_builder_image
    builder_type                        = var.codebuild_environment.default_builder_type
    builder_image_pull_credentials_type = var.codebuild_environment.default_builder_image_pull_credentials_type
    build_project_source                = var.codebuild_environment.default_build_project_source
    privileged_mode                     = false
  }

  amazonlinux2_based_build = {
    builder_compute_type                = var.codebuild_environment.default_builder_compute_type
    builder_image                       = var.codebuild_environment.amazonlinux2_builder_image
    builder_type                        = var.codebuild_environment.default_builder_type
    builder_image_pull_credentials_type = var.codebuild_environment.default_builder_image_pull_credentials_type
    build_project_source                = var.codebuild_environment.default_build_project_source
    privileged_mode                     = false
  }
}

locals {
  website_infra_build_projects = {
    validate = merge(local.amazonlinux2_based_build,
      { env_variables = {
        "ROLE_ARN"                             = module.website_infra_codepipeline_iam_role.terraform_role_arn,
        "TF_VAR_SLACK_WORKSPACE_ID"            = var.SLACK_WORKSPACE_ID,
        "TF_VAR_CI_CD_ALERTS_SLACK_CHANNEL_ID" = var.CI_CD_ALERTS_SLACK_CHANNEL_ID,
        "TS_ENV"                               = var.environment,
        "AWS_DEFAULT_REGION"                   = var.region,
        "PYTHON_VERSION"                       = var.runtime_versions.python,
        "RUBY_VERSION"                         = var.runtime_versions.ruby,
        "GOLANG_VERSION"                       = var.runtime_versions.golang
        "SCRIPT_DIR"                           = var.script_dir,
        }
    })

    plan = merge(local.amazonlinux2_based_build,
      { env_variables = {
        "ROLE_ARN"                             = module.website_infra_codepipeline_iam_role.terraform_role_arn,
        "TF_VAR_SLACK_WORKSPACE_ID"            = var.SLACK_WORKSPACE_ID,
        "TF_VAR_CI_CD_ALERTS_SLACK_CHANNEL_ID" = var.CI_CD_ALERTS_SLACK_CHANNEL_ID,
        "TS_ENV"                               = var.environment,
        "AWS_DEFAULT_REGION"                   = var.region,
        "PYTHON_VERSION"                       = var.runtime_versions.python,
        "RUBY_VERSION"                         = var.runtime_versions.ruby,
        "SCRIPT_DIR"                           = var.script_dir,
        }
    })

    up = merge(local.amazonlinux2_based_build,
      { env_variables = {
        "ROLE_ARN"                             = module.website_infra_codepipeline_iam_role.terraform_role_arn,
        "TF_VAR_SLACK_WORKSPACE_ID"            = var.SLACK_WORKSPACE_ID,
        "TF_VAR_CI_CD_ALERTS_SLACK_CHANNEL_ID" = var.CI_CD_ALERTS_SLACK_CHANNEL_ID,
        "TS_ENV"                               = var.environment,
        "AWS_DEFAULT_REGION"                   = var.region,
        "PYTHON_VERSION"                       = var.runtime_versions.python,
        "RUBY_VERSION"                         = var.runtime_versions.ruby,
        "SCRIPT_DIR"                           = var.script_dir,
        }
    })

    deploy = merge(local.ubuntu_based_build,
      { env_variables = {
        "NODEJS_VERSION"                = var.runtime_versions.nodejs,
        "BUCKET_NAME"                   = var.bucket_name,
        "SCRIPT_DIR"                    = var.script_dir,
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
        "ROLE_ARN"                             = module.website_infra_codepipeline_iam_role.terraform_role_arn,
        "TF_VAR_SLACK_WORKSPACE_ID"            = var.SLACK_WORKSPACE_ID,
        "TF_VAR_CI_CD_ALERTS_SLACK_CHANNEL_ID" = var.CI_CD_ALERTS_SLACK_CHANNEL_ID,
        "TS_ENV"                               = var.environment,
        "AWS_DEFAULT_REGION"                   = var.region,
        "PYTHON_VERSION"                       = var.runtime_versions.python,
        "RUBY_VERSION"                         = var.runtime_versions.ruby,
        "SCRIPT_DIR"                           = var.script_dir,
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
        "TF_VAR_CI_CD_ALERTS_SLACK_CHANNEL_ID" = var.CI_CD_ALERTS_SLACK_CHANNEL_ID,
        "TS_ENV"                               = var.environment,
        "AWS_DEFAULT_REGION"                   = var.region,
        "PYTHON_VERSION"                       = var.runtime_versions.python,
        "GOLANG_VERSION"                       = var.runtime_versions.golang
        "RUBY_VERSION"                         = var.runtime_versions.ruby,
        "SCRIPT_DIR"                           = var.script_dir,
        }
    })

    plan = merge(local.amazonlinux2_based_build,
      { env_variables = {
        "ROLE_ARN"                             = module.ci_cd_infra_codepipeline_iam_role.terraform_role_arn,
        "TF_VAR_SLACK_WORKSPACE_ID"            = var.SLACK_WORKSPACE_ID,
        "TF_VAR_CODEPIPELINE_SLACK_CHANNEL_ID" = var.CODEPIPELINE_SLACK_CHANNEL_ID,
        "TF_VAR_REPORT_SLACK_CHANNEL_ID"       = var.REPORT_SLACK_CHANNEL_ID,
        "TF_VAR_CI_CD_ALERTS_SLACK_CHANNEL_ID" = var.CI_CD_ALERTS_SLACK_CHANNEL_ID,
        "TS_ENV"                               = var.environment,
        "AWS_DEFAULT_REGION"                   = var.region,
        "PYTHON_VERSION"                       = var.runtime_versions.python,
        "RUBY_VERSION"                         = var.runtime_versions.ruby,
        "SCRIPT_DIR"                           = var.script_dir,
        }
    })

    up = merge(local.amazonlinux2_based_build,
      { env_variables = {
        "ROLE_ARN"                             = module.ci_cd_infra_codepipeline_iam_role.terraform_role_arn,
        "TF_VAR_SLACK_WORKSPACE_ID"            = var.SLACK_WORKSPACE_ID,
        "TF_VAR_REPORT_SLACK_CHANNEL_ID"       = var.REPORT_SLACK_CHANNEL_ID,
        "TF_VAR_CI_CD_ALERTS_SLACK_CHANNEL_ID" = var.CI_CD_ALERTS_SLACK_CHANNEL_ID,
        "TS_ENV"                               = var.environment,
        "AWS_DEFAULT_REGION"                   = var.region,
        "PYTHON_VERSION"                       = var.runtime_versions.python,
        "RUBY_VERSION"                         = var.runtime_versions.ruby,
        "SCRIPT_DIR"                           = var.script_dir,
        }
    })
  }

  ci_cd_website_build_projects = {

    batch_unit_mutation_lint = merge(local.ubuntu_based_build,
      { env_variables = {
        "NODEJS_VERSION"                = var.runtime_versions.nodejs,
        "PYTHON_VERSION"                = var.runtime_versions.python,
        "PW_TEST_HTML_REPORT_OPEN"      = "never",
        "WEBSITE_URL"                   = var.website_url,
        "ENVIRONMENT"                   = var.environment,
        "ACCOUNT_ID"                    = local.account_id
        "SCRIPT_DIR"                    = var.script_dir,
        "TEST_REPORTS_BUCKET"           = module.test_reports_bucket.name
        "WEBSITE_GIT_REPOSITORY_BRANCH" = var.website_repo_branch,
        "WEBSITE_GIT_REPOSITORY_LINK"   = "https://github.com/${var.source_repo_owner}/${var.website_content_repo_name}"
        }
    })
    deploy = merge(local.ubuntu_based_build,
      { env_variables = {
        "NODEJS_VERSION"                = var.runtime_versions.nodejs,
        "BUCKET_NAME"                   = var.bucket_name
        "SCRIPT_DIR"                    = var.script_dir,
        "ALARM_NAME"                    = local.alarm_name
        "WEBSITE_GIT_REPOSITORY_BRANCH" = var.website_repo_branch,
        "WEBSITE_GIT_REPOSITORY_LINK"   = "https://github.com/${var.source_repo_owner}/${var.website_content_repo_name}"
        }
    })

    healthcheck = merge(local.amazonlinux2_based_build,
      { env_variables = {
        "WEBSITE_URL" = var.website_url
        }
    })

    batch_pw = merge(local.ubuntu_based_build,
      { env_variables = {
        "NODEJS_VERSION"                = var.runtime_versions.nodejs,
        "PYTHON_VERSION"                = var.runtime_versions.python,
        "WEBSITE_URL"                   = var.website_url,
        "ENVIRONMENT"                   = var.environment,
        "ACCOUNT_ID"                    = local.account_id
        "SCRIPT_DIR"                    = var.script_dir,
        "PW_TEST_HTML_REPORT_OPEN"      = "never",
        "LHCI_REPORTS_BUCKET"           = module.lhci_reports_bucket.name
        "TEST_REPORTS_BUCKET"           = module.test_reports_bucket.name
        "WEBSITE_GIT_REPOSITORY_BRANCH" = var.website_repo_branch,
        "WEBSITE_GIT_REPOSITORY_LINK"   = "https://github.com/${var.source_repo_owner}/${var.website_content_repo_name}"
        }
    })
    batch_lhci_leak = merge(local.ubuntu_based_build,
      { env_variables = {
        "NODEJS_VERSION"                = var.runtime_versions.nodejs,
        "PYTHON_VERSION"                = var.runtime_versions.python,
        "WEBSITE_URL"                   = var.website_url,
        "ENVIRONMENT"                   = var.environment,
        "ACCOUNT_ID"                    = local.account_id
        "SCRIPT_DIR"                    = var.script_dir,
        "LHCI_REPORTS_BUCKET"           = module.lhci_reports_bucket.name
        "TEST_REPORTS_BUCKET"           = module.test_reports_bucket.name
        "WEBSITE_GIT_REPOSITORY_BRANCH" = var.website_repo_branch,
        "WEBSITE_GIT_REPOSITORY_LINK"   = "https://github.com/${var.source_repo_owner}/${var.website_content_repo_name}"
        }
    })
  }
}

