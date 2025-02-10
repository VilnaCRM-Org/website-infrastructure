module "ci_cd_infra_s3_artifacts_bucket" {
  source = "../../modules/aws/s3/codepipeline"

  project_name = var.ci_cd_infra_project_name

  region      = var.region
  environment = var.environment

  s3_artifacts_bucket_files_deletion_days = var.s3_artifacts_bucket_files_deletion_days

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

  website_bucket_name = var.bucket_name

  s3_bucket_arn           = module.ci_cd_infra_s3_artifacts_bucket.arn
  codestar_connection_arn = module.codestar_connection.arn

  policy_arns = merge(module.ci_cd_infra_policies.policy_arns, module.website_infra_policies.policy_arns)

  tags = var.tags

  depends_on = [module.ci_cd_infra_policies]
}

module "ci_cd_infra_codebuild" {
  source = "../../modules/aws/codebuild/stages"

  project_name   = var.ci_cd_infra_project_name
  build_projects = local.ci_cd_infra_build_projects

  s3_bucket_name   = module.ci_cd_infra_s3_artifacts_bucket.bucket
  role_arn         = module.ci_cd_infra_codepipeline_iam_role.role_arn
  github_token_arn = module.github_token_secret.secret_arn

  region      = var.region
  environment = var.environment

  tags = var.tags

  depends_on = [
    module.ci_cd_infra_s3_artifacts_bucket,
    module.ci_cd_infra_codepipeline_iam_role,
    module.codestar_connection
  ]
}

module "ci_cd_infra_codepipeline" {
  source = "../../modules/aws/codepipeline/infrastructure"

  project_name       = var.ci_cd_infra_project_name
  source_repo_owner  = var.source_repo_owner
  source_repo_name   = var.source_repo_name
  source_repo_branch = var.source_repo_branch
  detect_changes     = "true"

  stages = var.ci_cd_infra_stage_input

  region = var.region

  s3_bucket_name          = module.ci_cd_infra_s3_artifacts_bucket.bucket
  codepipeline_role_arn   = module.ci_cd_infra_codepipeline_iam_role.role_arn
  codestar_connection_arn = module.codestar_connection.arn

  tags = var.tags

  depends_on = [module.ci_cd_infra_codebuild, module.ci_cd_infra_s3_artifacts_bucket]
}

module "ci_cd_infra_pipeline_role" {
  source       = "../../modules/aws/iam/oidc/pipeline-trigger-role"
  role_name    = "ci-cd-infra-trigger-role"
  github_owner = var.source_repo_owner
  github_repo  = var.source_repo_name
  website_repo = var.website_content_repo_name
  branch       = var.source_repo_branch
  pipeline_arn = module.ci_cd_infra_codepipeline.arn
  depends_on   = [module.ci_cd_infra_codepipeline]
}