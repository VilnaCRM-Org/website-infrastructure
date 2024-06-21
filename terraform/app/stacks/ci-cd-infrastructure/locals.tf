locals {
  account_id = data.aws_caller_identity.current.account_id
  alarm_name = "website-${var.region}-s3-objects-anomaly-detection"

  website_infra_codebuild_project_down_name = "${var.website_infra_project_name}-down"

  website_infra_codebuild_project_down_source_configuration = {
    type      = "GITHUB"
    buildspec = "./aws/buildspecs/website/down.yml"
    location  = "https://github.com/${var.source_repo_owner}/${var.source_repo_name}"
    depth     = 1
    version   = var.source_repo_branch
  }

  codebuild_rollback_source_configuration = {
    type      = "GITHUB"
    buildspec = "./aws/buildspecs/website/release.yml"
    location  = "https://github.com/${var.source_repo_owner}/${var.source_repo_name}"
    depth     = 1
    version   = var.source_repo_branch
  }

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
        "ROLE_ARN"                               = module.website_infra_codepipeline_iam_role.terraform_role_arn,
        "TF_VAR_SLACK_WORKSPACE_ID"              = var.SLACK_WORKSPACE_ID,
        "TF_VAR_WEBSITE_ALERTS_SLACK_CHANNEL_ID" = var.WEBSITE_ALERTS_SLACK_CHANNEL_ID,
        "TS_ENV"                                 = var.environment,
        "AWS_DEFAULT_REGION"                     = var.region,
        "PYTHON_VERSION"                         = var.runtime_versions.python,
        "RUBY_VERSION"                           = var.runtime_versions.ruby,
        "GOLANG_VERSION"                         = var.runtime_versions.golang
        "SCRIPT_DIR"                             = var.script_dir,
        }
    })

    plan = merge(local.amazonlinux2_based_build,
      { env_variables = {
        "ROLE_ARN"                               = module.website_infra_codepipeline_iam_role.terraform_role_arn,
        "TF_VAR_SLACK_WORKSPACE_ID"              = var.SLACK_WORKSPACE_ID,
        "TF_VAR_WEBSITE_ALERTS_SLACK_CHANNEL_ID" = var.WEBSITE_ALERTS_SLACK_CHANNEL_ID,
        "TS_ENV"                                 = var.environment,
        "AWS_DEFAULT_REGION"                     = var.region,
        "PYTHON_VERSION"                         = var.runtime_versions.python,
        "RUBY_VERSION"                           = var.runtime_versions.ruby,
        "SCRIPT_DIR"                             = var.script_dir,
        }
    })

    up = merge(local.amazonlinux2_based_build,
      { env_variables = {
        "ROLE_ARN"                               = module.website_infra_codepipeline_iam_role.terraform_role_arn,
        "TF_VAR_SLACK_WORKSPACE_ID"              = var.SLACK_WORKSPACE_ID,
        "TF_VAR_WEBSITE_ALERTS_SLACK_CHANNEL_ID" = var.WEBSITE_ALERTS_SLACK_CHANNEL_ID,
        "TS_ENV"                                 = var.environment,
        "AWS_DEFAULT_REGION"                     = var.region,
        "PYTHON_VERSION"                         = var.runtime_versions.python,
        "RUBY_VERSION"                           = var.runtime_versions.ruby,
        "SCRIPT_DIR"                             = var.script_dir,
        "CI_CD_WEBSITE_PIPELINE_NAME"            = "${var.ci_cd_website_project_name}-pipeline"
        "CLOUDFRONT_REGION"                      = var.cloudfront_configuration.region
        }
    })
  }

  ci_cd_infra_build_projects = {
    validate = merge(local.amazonlinux2_based_build,
      { env_variables = {
        "ROLE_ARN"                               = module.ci_cd_infra_codepipeline_iam_role.terraform_role_arn,
        "TF_VAR_SLACK_WORKSPACE_ID"              = var.SLACK_WORKSPACE_ID,
        "TF_VAR_CODEPIPELINE_SLACK_CHANNEL_ID"   = var.CODEPIPELINE_SLACK_CHANNEL_ID,
        "TF_VAR_REPORT_SLACK_CHANNEL_ID"         = var.REPORT_SLACK_CHANNEL_ID,
        "TF_VAR_CI_CD_ALERTS_SLACK_CHANNEL_ID"   = var.CI_CD_ALERTS_SLACK_CHANNEL_ID,
        "TF_VAR_WEBSITE_ALERTS_SLACK_CHANNEL_ID" = var.WEBSITE_ALERTS_SLACK_CHANNEL_ID,
        "TS_ENV"                                 = var.environment,
        "AWS_DEFAULT_REGION"                     = var.region,
        "PYTHON_VERSION"                         = var.runtime_versions.python,
        "GOLANG_VERSION"                         = var.runtime_versions.golang
        "RUBY_VERSION"                           = var.runtime_versions.ruby,
        "SCRIPT_DIR"                             = var.script_dir,
        }
    })

    plan = merge(local.amazonlinux2_based_build,
      { env_variables = {
        "ROLE_ARN"                               = module.ci_cd_infra_codepipeline_iam_role.terraform_role_arn,
        "TF_VAR_SLACK_WORKSPACE_ID"              = var.SLACK_WORKSPACE_ID,
        "TF_VAR_CODEPIPELINE_SLACK_CHANNEL_ID"   = var.CODEPIPELINE_SLACK_CHANNEL_ID,
        "TF_VAR_REPORT_SLACK_CHANNEL_ID"         = var.REPORT_SLACK_CHANNEL_ID,
        "TF_VAR_CI_CD_ALERTS_SLACK_CHANNEL_ID"   = var.CI_CD_ALERTS_SLACK_CHANNEL_ID,
        "TF_VAR_WEBSITE_ALERTS_SLACK_CHANNEL_ID" = var.WEBSITE_ALERTS_SLACK_CHANNEL_ID,
        "TS_ENV"                                 = var.environment,
        "AWS_DEFAULT_REGION"                     = var.region,
        "PYTHON_VERSION"                         = var.runtime_versions.python,
        "RUBY_VERSION"                           = var.runtime_versions.ruby,
        "SCRIPT_DIR"                             = var.script_dir,
        "GITHUB_TOKEN"                           = var.GITHUB_TOKEN,
        "GITHUB_OWNER"                           = var.source_repo_owner,
        "TF_VAR_GITHUB_TOKEN"                    = var.GITHUB_TOKEN
        }
    })

    up = merge(local.amazonlinux2_based_build,
      { env_variables = {
        "ROLE_ARN"                               = module.ci_cd_infra_codepipeline_iam_role.terraform_role_arn,
        "TF_VAR_SLACK_WORKSPACE_ID"              = var.SLACK_WORKSPACE_ID,
        "TF_VAR_REPORT_SLACK_CHANNEL_ID"         = var.REPORT_SLACK_CHANNEL_ID,
        "TF_VAR_CI_CD_ALERTS_SLACK_CHANNEL_ID"   = var.CI_CD_ALERTS_SLACK_CHANNEL_ID,
        "TF_VAR_WEBSITE_ALERTS_SLACK_CHANNEL_ID" = var.WEBSITE_ALERTS_SLACK_CHANNEL_ID,
        "TS_ENV"                                 = var.environment,
        "AWS_DEFAULT_REGION"                     = var.region,
        "PYTHON_VERSION"                         = var.runtime_versions.python,
        "RUBY_VERSION"                           = var.runtime_versions.ruby,
        "SCRIPT_DIR"                             = var.script_dir,
        "GITHUB_TOKEN"                           = var.GITHUB_TOKEN,
        "GITHUB_OWNER"                           = var.source_repo_owner,
        "TF_VAR_GITHUB_TOKEN"                    = var.GITHUB_TOKEN
        }
    })
  }

  ci_cd_website_build_projects = {

    batch_unit_mutation_lint = merge(local.ubuntu_based_build,
      { env_variables = {
        "CI"                            = 1
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
        "CI"                            = 1
        "NODEJS_VERSION"                = var.runtime_versions.nodejs,
        "PYTHON_VERSION"                = var.runtime_versions.python,
        "BUCKET_NAME"                   = var.bucket_name
        "STAGING_BUCKET_NAME"           = "staging.${var.bucket_name}"
        "SCRIPT_DIR"                    = var.script_dir,
        "ALARM_NAME"                    = local.alarm_name
        "WEBSITE_GIT_REPOSITORY_BRANCH" = var.website_repo_branch,
        "WEBSITE_GIT_REPOSITORY_LINK"   = "https://github.com/${var.source_repo_owner}/${var.website_content_repo_name}"
        "CLOUDFRONT_REGION"             = var.cloudfront_configuration.region
        "CLOUDFRONT_WEIGHT"             = var.continuous_deployment_policy_weight
        "CLOUDFRONT_HEADER"             = var.continuous_deployment_policy_header
        }
    })

    healthcheck = merge(local.amazonlinux2_based_build,
      { env_variables = {
        "WEBSITE_URL" = var.website_url
        }
    })

    batch_pw_load = merge(local.ubuntu_based_build,
      { env_variables = {
        "CI"                            = 1
        "NODEJS_VERSION"                = var.runtime_versions.nodejs,
        "PYTHON_VERSION"                = var.runtime_versions.python,
        "WEBSITE_URL"                   = var.website_url,
        "ENVIRONMENT"                   = var.environment,
        "ACCOUNT_ID"                    = local.account_id
        "SCRIPT_DIR"                    = var.script_dir,
        "PW_TEST_HTML_REPORT_OPEN"      = "never",
        "CLOUDFRONT_HEADER"             = var.continuous_deployment_policy_header
        "GOLANG_VERSION"                = var.runtime_versions.golang
        "LHCI_REPORTS_BUCKET"           = module.lhci_reports_bucket.name
        "TEST_REPORTS_BUCKET"           = module.test_reports_bucket.name
        "WEBSITE_GIT_REPOSITORY_BRANCH" = var.website_repo_branch,
        "WEBSITE_GIT_REPOSITORY_LINK"   = "https://github.com/${var.source_repo_owner}/${var.website_content_repo_name}"
        }
    })

    batch_lhci_leak = merge(local.ubuntu_based_build,
      { env_variables = {
        "CI"                            = 1
        "NODEJS_VERSION"                = var.runtime_versions.nodejs,
        "PYTHON_VERSION"                = var.runtime_versions.python,
        "WEBSITE_URL"                   = var.website_url,
        "ENVIRONMENT"                   = var.environment,
        "ACCOUNT_ID"                    = local.account_id
        "SCRIPT_DIR"                    = var.script_dir,
        "CLOUDFRONT_HEADER"             = var.continuous_deployment_policy_header
        "LHCI_REPORTS_BUCKET"           = module.lhci_reports_bucket.name
        "TEST_REPORTS_BUCKET"           = module.test_reports_bucket.name
        "WEBSITE_GIT_REPOSITORY_BRANCH" = var.website_repo_branch,
        "WEBSITE_GIT_REPOSITORY_LINK"   = "https://github.com/${var.source_repo_owner}/${var.website_content_repo_name}"
        }
    })
    release = merge(local.ubuntu_based_build,
      { env_variables = {
        "PYTHON_VERSION"    = var.runtime_versions.python,
        "SCRIPT_DIR"        = var.script_dir,
        "CLOUDFRONT_REGION" = var.cloudfront_configuration.region
        }
    })
    trigger = merge(local.amazonlinux2_based_build,
      { env_variables = {
        "PROJECT_NAME" = local.website_infra_codebuild_project_down_name
        }
    })
  }

  website_infra_build_project_down_env_variables = {
    "ROLE_ARN"                               = module.website_infra_codepipeline_iam_role.terraform_role_arn,
    "TF_VAR_SLACK_WORKSPACE_ID"              = var.SLACK_WORKSPACE_ID,
    "TF_VAR_WEBSITE_ALERTS_SLACK_CHANNEL_ID" = var.WEBSITE_ALERTS_SLACK_CHANNEL_ID,
    "TS_ENV"                                 = var.environment,
    "AWS_DEFAULT_REGION"                     = var.region,
    "PYTHON_VERSION"                         = var.runtime_versions.python,
    "RUBY_VERSION"                           = var.runtime_versions.ruby,
    "SCRIPT_DIR"                             = var.script_dir,
  }

  codebuild_cloudfront_rollback_project_env_variables = {
    "CLOUDFRONT_REGION" = var.cloudfront_configuration.region
    "PYTHON_VERSION"    = var.runtime_versions.python,
    "SCRIPT_DIR"        = var.script_dir,
  }
}

