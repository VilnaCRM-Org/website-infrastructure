locals {
  account_id        = data.aws_caller_identity.current.account_id
  partition         = data.aws_partition.current.partition
  alarm_name        = "website-${var.region}-s3-objects-anomaly-detection"
  terraform_version = "1.14.3"
  terraform_runtime_env = {
    "TERRAFORM_VERSION" = local.terraform_version
    "TS_TERRAFORM_BIN"  = "terraform"
    "TS_VERSION_CHECK"  = "0"
  }

  codebuild_rollback_source_configuration = {
    type      = "GITHUB"
    buildspec = "./aws/buildspecs/website/release.yml"
    location  = "https://github.com/${var.source_repo_owner}/${var.source_repo_name}"
    depth     = 0
    version   = var.source_repo_branch
  }

  ubuntu_based_build = {
    builder_compute_type                = var.codebuild_environment.default_builder_compute_type
    builder_image                       = var.codebuild_environment.ubuntu_builder_image
    builder_type                        = var.codebuild_environment.default_builder_type
    builder_image_pull_credentials_type = var.codebuild_environment.default_builder_image_pull_credentials_type
    build_project_source                = var.codebuild_environment.default_build_project_source
    privileged_mode                     = true
  }

  amazonlinux2_based_build = {
    builder_compute_type                = var.codebuild_environment.default_builder_compute_type
    builder_image                       = var.codebuild_environment.amazonlinux2_builder_image
    builder_type                        = var.codebuild_environment.default_builder_type
    builder_image_pull_credentials_type = var.codebuild_environment.default_builder_image_pull_credentials_type
    build_project_source                = var.codebuild_environment.default_build_project_source
    privileged_mode                     = false
  }

  ecr_based_build = {
    builder_compute_type                = var.codebuild_environment.default_builder_compute_type
    builder_image                       = var.codebuild_environment.ecr_builder_image
    builder_type                        = var.codebuild_environment.default_builder_type
    builder_image_pull_credentials_type = var.codebuild_environment.default_builder_image_pull_credentials_type
    build_project_source                = var.codebuild_environment.default_build_project_source
    privileged_mode                     = true
  }
}

locals {
  website_infra_build_projects = {
    validate = merge(local.amazonlinux2_based_build,
      { env_variables = merge(local.terraform_runtime_env, {
        "ROLE_ARN"                               = module.website_infra_codepipeline_iam_role.terraform_role_arn,
        "TF_VAR_SLACK_WORKSPACE_ID"              = var.SLACK_WORKSPACE_ID,
        "TF_VAR_WEBSITE_ALERTS_SLACK_CHANNEL_ID" = var.WEBSITE_ALERTS_SLACK_CHANNEL_ID,
        "TS_ENV"                                 = var.environment,
        "AWS_DEFAULT_REGION"                     = var.region,
        "PYTHON_VERSION"                         = var.runtime_versions.python,
        "RUBY_VERSION"                           = var.runtime_versions.ruby,
        "GOLANG_VERSION"                         = var.runtime_versions.golang,
        "SCRIPT_DIR"                             = var.script_dir,
        })
      },
    { buildspec = "./aws/buildspecs/${var.website_buildspecs}/validate.yml" })

    plan = merge(local.amazonlinux2_based_build,
      { env_variables = merge(local.terraform_runtime_env, {
        "ROLE_ARN"                               = module.website_infra_codepipeline_iam_role.terraform_role_arn,
        "TF_VAR_SLACK_WORKSPACE_ID"              = var.SLACK_WORKSPACE_ID,
        "TF_VAR_WEBSITE_ALERTS_SLACK_CHANNEL_ID" = var.WEBSITE_ALERTS_SLACK_CHANNEL_ID,
        "TS_ENV"                                 = var.environment,
        "AWS_DEFAULT_REGION"                     = var.region,
        "RUBY_VERSION"                           = var.runtime_versions.ruby,
        "SCRIPT_DIR"                             = var.script_dir,
        })
      },
    { buildspec = "./aws/buildspecs/${var.website_buildspecs}/plan.yml" })

    up = merge(local.amazonlinux2_based_build,
      { env_variables = merge(local.terraform_runtime_env, {
        "ROLE_ARN"                               = module.website_infra_codepipeline_iam_role.terraform_role_arn,
        "TF_VAR_SLACK_WORKSPACE_ID"              = var.SLACK_WORKSPACE_ID,
        "TF_VAR_WEBSITE_ALERTS_SLACK_CHANNEL_ID" = var.WEBSITE_ALERTS_SLACK_CHANNEL_ID,
        "TS_ENV"                                 = var.environment,
        "AWS_DEFAULT_REGION"                     = var.region,
        "PYTHON_VERSION"                         = var.runtime_versions.python,
        "RUBY_VERSION"                           = var.runtime_versions.ruby,
        "SCRIPT_DIR"                             = var.script_dir,
        "BUCKET_NAME"                            = var.bucket_name,
        "CI_CD_WEBSITE_PIPELINE_NAME"            = "${var.ci_cd_website_project_name}-pipeline",
        "CLOUDFRONT_REGION"                      = var.cloudfront_configuration.region,
        })
      },
    { buildspec = "./aws/buildspecs/${var.website_buildspecs}/up.yml" })
  }

  ci_cd_infra_build_projects = {
    validate = merge(local.amazonlinux2_based_build,
      { env_variables = merge(local.terraform_runtime_env, {
        "ROLE_ARN"                               = module.ci_cd_infra_codepipeline_iam_role.terraform_role_arn,
        "TF_VAR_SLACK_WORKSPACE_ID"              = var.SLACK_WORKSPACE_ID,
        "TF_VAR_CODEPIPELINE_SLACK_CHANNEL_ID"   = var.CODEPIPELINE_SLACK_CHANNEL_ID,
        "TF_VAR_REPORT_SLACK_CHANNEL_ID"         = var.REPORT_SLACK_CHANNEL_ID,
        "TF_VAR_CI_CD_ALERTS_SLACK_CHANNEL_ID"   = var.CI_CD_ALERTS_SLACK_CHANNEL_ID,
        "TF_VAR_WEBSITE_ALERTS_SLACK_CHANNEL_ID" = var.WEBSITE_ALERTS_SLACK_CHANNEL_ID,
        "TS_ENV"                                 = var.environment,
        "AWS_DEFAULT_REGION"                     = var.region,
        "PYTHON_VERSION"                         = var.runtime_versions.python,
        "GOLANG_VERSION"                         = var.runtime_versions.golang,
        "RUBY_VERSION"                           = var.runtime_versions.ruby,
        "SCRIPT_DIR"                             = var.script_dir,
        })
      },
    { buildspec = "./aws/buildspecs/${var.ci_cd_infra_buildspecs}/validate.yml" })

    plan = merge(local.amazonlinux2_based_build,
      { env_variables = merge(local.terraform_runtime_env, {
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
        "GITHUB_OWNER"                           = var.source_repo_owner,
        })
      },
    { buildspec = "./aws/buildspecs/${var.ci_cd_infra_buildspecs}/plan.yml" })

    up = merge(local.amazonlinux2_based_build,
      { env_variables = merge(local.terraform_runtime_env, {
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
        "GITHUB_OWNER"                           = var.source_repo_owner,
        })
      },
    { buildspec = "./aws/buildspecs/${var.ci_cd_infra_buildspecs}/up.yml" })
  }

  ci_cd_website_build_projects = {
    batch_unit_mutation_lint = merge(local.ecr_based_build,
      { build_batch_config = {
        combine_artifacts = true
        }
      },
      { env_variables = {
        "CI"                            = 1
        "NODEJS_VERSION"                = var.runtime_versions.nodejs,
        "PYTHON_VERSION"                = var.runtime_versions.python,
        "PW_TEST_HTML_REPORT_OPEN"      = "never",
        "WEBSITE_URL"                   = var.website_url,
        "ENVIRONMENT"                   = var.environment,
        "ACCOUNT_ID"                    = local.account_id,
        "SCRIPT_DIR"                    = var.script_dir,
        "TEST_REPORTS_BUCKET"           = module.test_reports_bucket.id,
        "WEBSITE_GIT_REPOSITORY_BRANCH" = var.website_repo_branch,
        "WEBSITE_GIT_REPOSITORY_LINK"   = "https://github.com/${var.source_repo_owner}/${var.website_content_repo_name}",
        }
      },
    { buildspec = "./aws/buildspecs/${var.website_buildspecs}/batch_unit_mutation_lint.yml" })

    deploy = merge(local.ubuntu_based_build,
      { build_batch_config = null },
      { env_variables = {
        "CI"                            = 1
        "NODEJS_VERSION"                = var.runtime_versions.nodejs,
        "PYTHON_VERSION"                = var.runtime_versions.python,
        "BUCKET_NAME"                   = var.bucket_name,
        "SCRIPT_DIR"                    = var.script_dir,
        "ALARM_NAME"                    = local.alarm_name,
        "WEBSITE_GIT_REPOSITORY_BRANCH" = var.website_repo_branch,
        "WEBSITE_GIT_REPOSITORY_LINK"   = "https://github.com/${var.source_repo_owner}/${var.website_content_repo_name}",
        "CLOUDFRONT_REGION"             = var.cloudfront_configuration.region,
        "CLOUDFRONT_WEIGHT"             = var.continuous_deployment_policy_weight,
        "CLOUDFRONT_HEADER"             = var.continuous_deployment_policy_header,
        }
      },
    { buildspec = "./aws/buildspecs/${var.website_buildspecs}/deploy.yml" })

    healthcheck = merge(local.amazonlinux2_based_build,
      { build_batch_config = null },
      { env_variables = {
        "WEBSITE_URL" = var.website_url
        }
      },
    { buildspec = "./aws/buildspecs/${var.website_buildspecs}/healthcheck.yml" })

    batch_pw_load = merge(local.ecr_based_build,
      { build_batch_config = {
        combine_artifacts = true
        }
      },
      { env_variables = {
        "CI"                            = 1
        "NODEJS_VERSION"                = var.runtime_versions.nodejs,
        "PYTHON_VERSION"                = var.runtime_versions.python,
        "GOLANG_VERSION"                = var.runtime_versions.golang,
        "WEBSITE_URL"                   = var.website_url,
        "ENVIRONMENT"                   = var.environment,
        "ACCOUNT_ID"                    = local.account_id,
        "SCRIPT_DIR"                    = var.script_dir,
        "PW_TEST_HTML_REPORT_OPEN"      = "never",
        "CLOUDFRONT_HEADER"             = var.continuous_deployment_policy_header,
        "LHCI_REPORTS_BUCKET"           = module.lhci_reports_bucket.id,
        "TEST_REPORTS_BUCKET"           = module.test_reports_bucket.id,
        "WEBSITE_GIT_REPOSITORY_BRANCH" = var.website_repo_branch,
        "WEBSITE_GIT_REPOSITORY_LINK"   = "https://github.com/${var.source_repo_owner}/${var.website_content_repo_name}",
        }
      },
    { buildspec = "./aws/buildspecs/${var.website_buildspecs}/batch_pw_load.yml" })

    batch_lhci_leak = merge(local.ecr_based_build,
      { build_batch_config = {
        combine_artifacts = true
        }
      },
      { env_variables = {
        "CI"                            = 1
        "NODEJS_VERSION"                = var.runtime_versions.nodejs,
        "PYTHON_VERSION"                = var.runtime_versions.python,
        "WEBSITE_URL"                   = var.website_url,
        "ENVIRONMENT"                   = var.environment,
        "ACCOUNT_ID"                    = local.account_id,
        "SCRIPT_DIR"                    = var.script_dir,
        "CLOUDFRONT_HEADER"             = var.continuous_deployment_policy_header,
        "LHCI_REPORTS_BUCKET"           = module.lhci_reports_bucket.id,
        "TEST_REPORTS_BUCKET"           = module.test_reports_bucket.id,
        "WEBSITE_GIT_REPOSITORY_BRANCH" = var.website_repo_branch,
        "WEBSITE_GIT_REPOSITORY_LINK"   = "https://github.com/${var.source_repo_owner}/${var.website_content_repo_name}",
        }
      },
    { buildspec = "./aws/buildspecs/${var.website_buildspecs}/batch_lhci_leak.yml" })

    release = merge(local.ubuntu_based_build,
      { build_batch_config = null },
      { env_variables = {
        "PYTHON_VERSION"    = var.runtime_versions.python,
        "SCRIPT_DIR"        = var.script_dir,
        "CLOUDFRONT_REGION" = var.cloudfront_configuration.region,
        }
      },
    { buildspec = "./aws/buildspecs/${var.website_buildspecs}/release.yml" })

  }

  codebuild_cloudfront_rollback_project_env_variables = {
    "CLOUDFRONT_REGION" = var.cloudfront_configuration.region,
    "PYTHON_VERSION"    = var.runtime_versions.python,
    "SCRIPT_DIR"        = var.script_dir,
  }

  common_sandbox_env_variables = {
    "AWS_DEFAULT_REGION" = var.region,
    "PYTHON_VERSION"     = var.runtime_versions.python,
    "SCRIPT_DIR"         = var.script_dir,
    "PROJECT_NAME"       = var.sandbox_project_name,
    "GITHUB_REPOSITORY"  = "${var.source_repo_owner}/${var.website_content_repo_name}",
  }

  sandbox_branch_hash_length        = 8
  sandbox_branch_hash               = substr(sha1(var.BRANCH_NAME), 0, local.sandbox_branch_hash_length)
  sandbox_branch_slug               = replace(lower(var.BRANCH_NAME), "/[^a-z0-9]+/", "-")
  sandbox_branch_trimmed            = replace(local.sandbox_branch_slug, "/^-+|-+$/", "")
  sandbox_branch_base               = local.sandbox_branch_trimmed != "" ? local.sandbox_branch_trimmed : "branch"
  sandbox_bucket_suffix_max_length  = max(10, 63 - length(var.sandbox_project_name) - 1)
  sandbox_bucket_hash_suffix_length = local.sandbox_branch_hash_length + 1
  sandbox_branch_prefix_max_length  = max(1, local.sandbox_bucket_suffix_max_length - local.sandbox_bucket_hash_suffix_length)
  sandbox_branch_prefix             = replace(substr(local.sandbox_branch_base, 0, local.sandbox_branch_prefix_max_length), "/-+$/", "")
  sanitized_sandbox_branch_name     = "${local.sandbox_branch_prefix != "" ? local.sandbox_branch_prefix : "branch"}-${local.sandbox_branch_hash}"

  sandbox_build_projects = {
    up = merge(local.amazonlinux2_based_build,
      {
        env_variables = merge(
          local.common_sandbox_env_variables,
          {
            "ROLE_ARN" = module.sandbox_codepipeline_iam_role.terraform_role_arn,
            "TS_ENV"   = var.environment,
          }
        )
      },
    { buildspec = "./aws/buildspecs/${var.sandbox_buildspecs}/up.yml" })

    deploy = merge(local.ecr_based_build,
      {
        env_variables = merge(
          local.common_sandbox_env_variables,
          {
            "CI"                          = "1",
            "NODEJS_VERSION"              = var.runtime_versions.nodejs,
            "BUCKET_NAME"                 = var.bucket_name,
            "WEBSITE_GIT_REPOSITORY_LINK" = "https://github.com/${var.source_repo_owner}/${var.website_content_repo_name}",
          }
        )
      },
    { buildspec = "./aws/buildspecs/${var.sandbox_buildspecs}/deploy.yml" })

    healthcheck = merge(local.amazonlinux2_based_build,
      {
        env_variables = merge(
          local.common_sandbox_env_variables,
          {
            "BRANCH_NAME" = var.BRANCH_NAME,
          }
        )
      },
    { buildspec = "./aws/buildspecs/${var.sandbox_buildspecs}/healthcheck.yml" })
  }

  sandbox_delete_projects = {
    delete = merge(
      local.amazonlinux2_based_build,
      {
        project_name = "${var.project_name}-delete"
        env_variables = merge(
          local.common_sandbox_env_variables,
          {
            "BRANCH_NAME" = var.BRANCH_NAME,
          }
        )
      },
    { buildspec = "./aws/buildspecs/${var.sandbox_buildspecs}/delete.yml" })
  }
}
