module "codestar_connection" {
  source = "../../modules/aws/codestar"

  github_connection_name = var.github_connection_name

  tags = var.tags
}

module "ci_cd_infra_policies" {
  source = "../../modules/aws/iam/policies/codepipeline"

  policy_prefix        = "${var.environment}-ci-cd-infra"
  website_project_name = var.website_infra_project_name
  ci_cd_project_name   = var.ci_cd_infra_project_name
  region               = var.region
  environment          = var.environment

  tags = var.tags
}

module "website_infra_policies" {
  source = "../../modules/aws/iam/policies/website"

  project_name  = var.project_name
  policy_prefix = "${var.environment}-website-infra"
  region        = var.region
  environment   = var.environment
  domain_name   = var.website_url

  tags = var.tags
}

module "ci_cd_infra_s3_artifacts_bucket" {
  source = "../../modules/aws/s3/codepipeline-s3"

  project_name = var.ci_cd_infra_project_name

  region      = var.region
  environment = var.environment

  kms_key_arn           = module.ci_cd_infra_codepipeline_kms.arn
  codepipeline_role_arn = module.ci_cd_infra_codepipeline_iam_role.role_arn

  tags = var.tags
}

module "ci_cd_infra_codepipeline_kms" {
  source = "../../modules/aws/kms"

  codepipeline_role_arn = module.ci_cd_infra_codepipeline_iam_role.role_arn

  tags = var.tags
}

module "ci_cd_infra_codepipeline_iam_role" {
  source = "../../modules/aws/iam/roles/codepipeline-role"

  project_name = var.ci_cd_infra_project_name

  codepipeline_iam_role_name = "${var.ci_cd_infra_project_name}-codepipeline-role"
  source_repo_owner          = var.source_repo_owner
  source_repo_name           = var.source_repo_name

  region      = var.region
  environment = var.environment

  kms_key_arn             = module.ci_cd_infra_codepipeline_kms.arn
  s3_bucket_arn           = module.ci_cd_infra_s3_artifacts_bucket.arn
  codestar_connection_arn = module.codestar_connection.arn

  policy_arns = merge(module.ci_cd_infra_policies.policy_arns, module.website_infra_policies.policy_arns)

  tags = var.tags

  depends_on = [module.ci_cd_infra_policies]
}

module "ci_cd_infra_codebuild" {
  source = "../../modules/aws/codebuild"

  project_name                        = var.ci_cd_infra_project_name
  build_projects                      = var.ci_cd_infra_build_projects
  build_project_source                = var.build_project_source
  builder_compute_type                = var.builder_compute_type
  builder_image                       = var.builder_image
  builder_image_pull_credentials_type = var.builder_image_pull_credentials_type
  builder_type                        = var.builder_type

  s3_bucket_name = module.ci_cd_infra_s3_artifacts_bucket.bucket
  role_arn       = module.ci_cd_infra_codepipeline_iam_role.role_arn
  kms_key_arn    = module.ci_cd_infra_codepipeline_kms.arn

  stack = var.ci_cd_infra_buildspecs

  region      = var.region
  environment = var.environment

  environment_variables = merge(local.environment_variables, { "ROLE_ARN" = module.ci_cd_infra_codepipeline_iam_role.terraform_role_arn })

  tags = var.tags

  depends_on = [
    module.ci_cd_infra_s3_artifacts_bucket,
    module.ci_cd_infra_codepipeline_iam_role,
    module.ci_cd_infra_codepipeline_kms,
    module.codestar_connection
  ]
}

module "ci_cd_infra_codepipeline" {
  source = "../../modules/aws/codepipeline"

  project_name       = var.ci_cd_infra_project_name
  source_repo_owner  = var.source_repo_owner
  source_repo_name   = var.source_repo_name
  source_repo_branch = var.source_repo_branch

  stages = var.ci_cd_infra_stage_input

  region = var.region

  s3_bucket_name          = module.ci_cd_infra_s3_artifacts_bucket.bucket
  codepipeline_role_arn   = module.ci_cd_infra_codepipeline_iam_role.role_arn
  kms_key_arn             = module.ci_cd_infra_codepipeline_kms.arn
  codestar_connection_arn = module.codestar_connection.arn

  tags = var.tags

  depends_on = [module.ci_cd_infra_codebuild, module.ci_cd_infra_s3_artifacts_bucket]
}

module "website_infra_s3_artifacts_bucket" {
  source = "../../modules/aws/s3/codepipeline-s3"

  project_name = var.website_infra_project_name

  region      = var.region
  environment = var.environment

  kms_key_arn           = module.website_infra_codepipeline_kms.arn
  codepipeline_role_arn = module.website_infra_codepipeline_iam_role.role_arn

  tags = var.tags
}

module "website_infra_codepipeline_kms" {
  source = "../../modules/aws/kms"

  codepipeline_role_arn = module.website_infra_codepipeline_iam_role.role_arn

  tags = var.tags
}

module "website_infra_codepipeline_iam_role" {
  source = "../../modules/aws/iam/roles/codepipeline-role"

  project_name               = var.website_infra_project_name
  codepipeline_iam_role_name = "${var.website_infra_project_name}-codepipeline-role"

  source_repo_owner = var.source_repo_owner
  source_repo_name  = var.source_repo_name

  region      = var.region
  environment = var.environment

  kms_key_arn             = module.website_infra_codepipeline_kms.arn
  s3_bucket_arn           = module.website_infra_s3_artifacts_bucket.arn
  codestar_connection_arn = module.codestar_connection.arn

  policy_arns = module.website_infra_policies.policy_arns

  tags = var.tags

  depends_on = [module.website_infra_policies]
}

module "website_infra_codebuild" {
  source = "../../modules/aws/codebuild"

  project_name                        = var.website_infra_project_name
  build_projects                      = var.website_infra_build_projects
  build_project_source                = var.build_project_source
  builder_compute_type                = var.builder_compute_type
  builder_image                       = var.builder_image
  builder_image_pull_credentials_type = var.builder_image_pull_credentials_type
  builder_type                        = var.builder_type

  region      = var.region
  environment = var.environment

  stack = var.website_infra_buildspecs

  s3_bucket_name = module.website_infra_s3_artifacts_bucket.bucket
  role_arn       = module.website_infra_codepipeline_iam_role.role_arn
  kms_key_arn    = module.website_infra_codepipeline_kms.arn

  environment_variables = merge(local.environment_variables, { "ROLE_ARN" = module.website_infra_codepipeline_iam_role.terraform_role_arn })

  tags = var.tags

  depends_on = [
    module.website_infra_s3_artifacts_bucket,
    module.website_infra_codepipeline_iam_role,
    module.website_infra_codepipeline_kms,
    module.codestar_connection
  ]
}

module "website_infra_codepipeline" {
  source = "../../modules/aws/codepipeline"

  project_name       = var.website_infra_project_name
  source_repo_owner  = var.source_repo_owner
  source_repo_name   = var.source_repo_name
  source_repo_branch = var.source_repo_branch

  stages = var.website_infra_stage_input

  region = var.region

  s3_bucket_name          = module.website_infra_s3_artifacts_bucket.bucket
  codepipeline_role_arn   = module.website_infra_codepipeline_iam_role.role_arn
  kms_key_arn             = module.website_infra_codepipeline_kms.arn
  codestar_connection_arn = module.codestar_connection.arn

  tags = var.tags

  depends_on = [module.website_infra_codebuild, module.website_infra_s3_artifacts_bucket]
}


module "chatbot" {
  count = var.create_slack_notification ? 1 : 0

  source = "../../modules/aws/chatbot"

  project_name = "codepipeline"
  channel_id   = var.CODEPIPELINE_SLACK_CHANNEL_ID
  workspace_id = var.SLACK_WORKSPACE_ID

  sns_topic_arns = [module.website_infra_codepipeline.sns_topic_arn, module.ci_cd_infra_codepipeline.sns_topic_arn]

  tags = var.tags

  depends_on = [module.website_infra_codepipeline, module.ci_cd_infra_codepipeline]
}