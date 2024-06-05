module "website_infra_s3_artifacts_bucket" {
  source = "../../modules/aws/s3/codepipeline"

  project_name = var.website_infra_project_name

  region      = var.region
  environment = var.environment

  s3_artifacts_bucket_files_deletion_days = var.s3_artifacts_bucket_files_deletion_days

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

  website_bucket_name = var.bucket_name

  kms_key_arn             = module.website_infra_codepipeline_kms.arn
  s3_bucket_arn           = module.website_infra_s3_artifacts_bucket.arn
  codestar_connection_arn = module.codestar_connection.arn

  policy_arns = module.website_infra_policies.policy_arns

  tags = var.tags

  depends_on = [module.website_infra_policies]
}

module "website_infra_codebuild" {
  source = "../../modules/aws/codebuild/stages"

  project_name   = var.website_infra_project_name
  build_projects = local.website_infra_build_projects

  region      = var.region
  environment = var.environment

  codepipeline_buildspecs = var.website_infra_buildspecs

  s3_bucket_name = module.website_infra_s3_artifacts_bucket.bucket
  role_arn       = module.website_infra_codepipeline_iam_role.role_arn
  kms_key_arn    = module.website_infra_codepipeline_kms.arn

  tags = var.tags

  depends_on = [
    module.website_infra_s3_artifacts_bucket,
    module.website_infra_codepipeline_iam_role,
    module.website_infra_codepipeline_kms,
    module.codestar_connection
  ]
}

module "website_infra_codebuild_down" {
  source = "../../modules/aws/codebuild/project"

  project_name = "website-down"

  region      = var.region
  environment = var.environment

  build_configuration = local.amazonlinux2_based_build
  env_variables = local.website_infra_build_project_down_env_variables
  
  role_arn    = module.website_infra_codepipeline_iam_role.role_arn
  kms_key_arn = module.website_infra_codepipeline_kms.arn

  tags = var.tags

  depends_on = [
    module.website_infra_s3_artifacts_bucket,
    module.website_infra_codepipeline_iam_role,
    module.website_infra_codepipeline_kms,
    module.codestar_connection
  ]
}

module "website_infra_codepipeline" {
  source = "../../modules/aws/codepipeline/infrastructure"

  project_name       = var.website_infra_project_name
  source_repo_owner  = var.source_repo_owner
  source_repo_name   = var.source_repo_name
  source_repo_branch = var.source_repo_branch
  detect_changes     = "true"

  stages = var.website_infra_stage_input

  region = var.region

  s3_bucket_name          = module.website_infra_s3_artifacts_bucket.bucket
  codepipeline_role_arn   = module.website_infra_codepipeline_iam_role.role_arn
  kms_key_arn             = module.website_infra_codepipeline_kms.arn
  codestar_connection_arn = module.codestar_connection.arn

  tags = var.tags

  depends_on = [module.website_infra_codebuild, module.website_infra_s3_artifacts_bucket]
}