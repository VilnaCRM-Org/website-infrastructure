module "codestar_connection" {
  source = "../../modules/aws/codestar"

  github_connection_name = var.github_connection_name

  tags = var.tags
}

module "s3_artifacts_bucket" {
  source = "../../modules/aws/s3/codepipeline-s3"

  project_name = var.project_name

  region      = var.region
  environment = var.environment

  kms_key_arn           = module.codepipeline_kms.arn
  codepipeline_role_arn = module.codepipeline_iam_role.role_arn

  tags = var.tags
}

module "codepipeline_kms" {
  source = "../../modules/aws/kms"

  codepipeline_role_arn       = module.codepipeline_iam_role.role_arn
  kms_condition_account_value = var.kms_condition_account_value

  tags = var.tags
}

module "codepipeline_iam_role" {
  source = "../../modules/aws/iam-role"

  project_name               = var.project_name
  create_new_role            = var.create_new_role
  codepipeline_iam_role_name = var.create_new_role == true ? "${var.project_name}-codepipeline-role" : var.codepipeline_iam_role_name

  source_repo_owner          = var.source_repo_owner
  source_repo_name           = var.source_repo_name
  secretsmanager_secret_name = var.secretsmanager_secret_name

  region      = var.region
  environment = var.environment

  kms_key_arn             = module.codepipeline_kms.arn
  s3_bucket_arn           = module.s3_artifacts_bucket.arn
  codestar_connection_arn = module.codestar_connection.arn

  tags = var.tags
}

module "codebuild_terraform" {
  source = "../../modules/aws/codebuild"

  project_name                        = var.project_name
  build_projects                      = var.build_projects
  build_project_source                = var.build_project_source
  builder_compute_type                = var.builder_compute_type
  builder_image                       = var.builder_image
  builder_image_pull_credentials_type = var.builder_image_pull_credentials_type
  builder_type                        = var.builder_type

  ruby_version   = var.ruby_version
  python_version = var.python_version
  nodejs_version = var.nodejs_version
  bucket_name    = var.bucket_name
  script_dir     = var.script_dir

  region      = var.region
  environment = var.environment

  SLACK_WORKSPACE_ID            = var.SLACK_WORKSPACE_ID
  CODEPIPELINE_SLACK_CHANNEL_ID = var.CODEPIPELINE_SLACK_CHANNEL_ID
  ALERTS_SLACK_CHANNEL_ID       = var.ALERTS_SLACK_CHANNEL_ID

  website_url = var.website_url

  secretsmanager_secret_name = var.secretsmanager_secret_name

  s3_bucket_name = module.s3_artifacts_bucket.bucket
  role_arn       = module.codepipeline_iam_role.role_arn
  kms_key_arn    = module.codepipeline_kms.arn

  tags = var.tags

  depends_on = [
    module.s3_artifacts_bucket,
    module.codepipeline_iam_role,
    module.codepipeline_kms,
    module.codestar_connection
  ]
}

module "codepipeline_terraform" {
  source = "../../modules/aws/codepipeline"

  project_name       = var.project_name
  source_repo_owner  = var.source_repo_owner
  source_repo_name   = var.source_repo_name
  source_repo_branch = var.source_repo_branch

  stages = var.stage_input

  region = var.region

  s3_bucket_name          = module.s3_artifacts_bucket.bucket
  codepipeline_role_arn   = module.codepipeline_iam_role.role_arn
  kms_key_arn             = module.codepipeline_kms.arn
  codestar_connection_arn = module.codestar_connection.arn

  tags = var.tags

  depends_on = [module.codebuild_terraform, module.s3_artifacts_bucket]
}


module "chatbot" {
  count = var.create_slack_notification ? 1 : 0
  
  source = "../../modules/aws/chatbot"

  project_name = "codepipeline"
  channel_id   = var.CODEPIPELINE_SLACK_CHANNEL_ID
  workspace_id = var.SLACK_WORKSPACE_ID

  sns_topic_arn = module.codepipeline_terraform.sns_topic_arn

  tags = var.tags

  depends_on = [module.codepipeline_terraform]
}