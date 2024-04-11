locals {
  account_id = data.aws_caller_identity.current.account_id
  environment_variables = {
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
}

