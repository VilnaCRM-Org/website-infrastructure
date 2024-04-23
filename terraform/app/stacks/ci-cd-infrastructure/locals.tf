locals {
  ubuntu_based_build = {
    builder_compute_type                = var.default_builder_compute_type
    builder_image                       = var.ubuntu_builder_image
    builder_type                        = var.default_builder_type
    privileged_mode                     = false
    builder_image_pull_credentials_type = var.default_builder_image_pull_credentials_type
    build_project_source                = var.default_build_project_source
  }

  amazonlinux2_based_build = {
    builder_compute_type                = var.default_builder_compute_type
    builder_image                       = var.amazonlinux2_builder_image
    builder_type                        = var.default_builder_type
    privileged_mode                     = false
    builder_image_pull_credentials_type = var.default_builder_image_pull_credentials_type
    build_project_source                = var.default_build_project_source
  }
}

locals {
  infra_environment_variables = {
    "TS_ENV"                               = var.environment,
    "AWS_DEFAULT_REGION"                   = var.region,
    "TF_VAR_SLACK_WORKSPACE_ID"            = var.SLACK_WORKSPACE_ID,
    "TF_VAR_CODEPIPELINE_SLACK_CHANNEL_ID" = var.CODEPIPELINE_SLACK_CHANNEL_ID,
    "TF_VAR_ALERTS_SLACK_CHANNEL_ID"       = var.ALERTS_SLACK_CHANNEL_ID,
    "WEBSITE_URL"                          = var.website_url,
    "PYTHON_VERSION"                       = var.python_version,
    "RUBY_VERSION"                         = var.ruby_version,
    "NODEJS_VERSION"                       = var.nodejs_version,
    "SCRIPT_DIR"                           = var.script_dir,
    "BUCKET_NAME"                          = var.bucket_name,
  }

  deploy_environment_variables = {
    "WEBSITE_URL"    = var.website_url,
    "NODEJS_VERSION" = var.nodejs_version,
    "BUCKET_NAME"    = var.bucket_name,
    "SCRIPT_DIR"     = var.script_dir,
    "PW_TEST_HTML_REPORT_OPEN" = "never"
  }

  ci_cd_infra_build_projects = {
    validate = local.amazonlinux2_based_build
    plan     = local.amazonlinux2_based_build
    up       = local.amazonlinux2_based_build
  }

  website_infra_build_projects = {
    validate    = local.amazonlinux2_based_build
    plan        = local.amazonlinux2_based_build
    up          = local.amazonlinux2_based_build
    deploy      = local.ubuntu_based_build
    healthcheck = local.amazonlinux2_based_build
    down        = local.amazonlinux2_based_build
  }

  ci_cd_website_build_projects = {
    test        = local.ubuntu_based_build
    lint        = local.ubuntu_based_build
    deploy      = local.ubuntu_based_build
    healthcheck = local.amazonlinux2_based_build
    lighthouse  = local.ubuntu_based_build
  }
}

