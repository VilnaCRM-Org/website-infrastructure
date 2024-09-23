module "sandbox_s3_artifacts_bucket" {
  source = "../../modules/aws/s3/codepipeline"

  project_name = var.sandbox_project_name

  region      = var.region
  environment = var.environment

  s3_artifacts_bucket_files_deletion_days = var.s3_artifacts_bucket_files_deletion_days

  kms_key_arn           = module.sandbox_codepipeline_kms.arn
  codepipeline_role_arn = module.sandbox_codepipeline_iam_role.role_arn

  tags = var.tags

}

module "sandbox_codepipeline_kms" {
  source = "../../modules/aws/kms"

  codepipeline_role_arn = module.sandbox_codepipeline_iam_role.role_arn

  tags = var.tags
}

module "sandbox_codepipeline_iam_role" {
  source = "../../modules/aws/iam/roles/sandbox-codepipeline-role"

  project_name = var.sandbox_project_name

  codepipeline_iam_role_name = "${var.sandbox_project_name}-codepipeline-role"
  source_repo_owner          = var.source_repo_owner
  source_repo_name           = var.source_repo_name

  region      = var.region
  environment = var.environment

  kms_key_arn             = module.sandbox_codepipeline_kms.arn
  s3_bucket_arn           = module.sandbox_s3_artifacts_bucket.arn
  codestar_connection_arn = module.codestar_connection.arn

  policy_arns = module.sandbox_policies.policy_arns

  tags = var.tags

  depends_on = [module.sandbox_policies]
}

module "sandbox_codebuild" {
  source = "../../modules/aws/codebuild/stages"

  project_name   = var.sandbox_project_name
  build_projects = local.sandbox_build_projects

  s3_bucket_name = module.sandbox_s3_artifacts_bucket.bucket
  role_arn       = module.sandbox_codepipeline_iam_role.role_arn
  kms_key_arn    = module.sandbox_codepipeline_kms.arn

  region      = var.region
  environment = var.environment

  tags = var.tags

  depends_on = [
    module.sandbox_s3_artifacts_bucket,
    module.sandbox_codepipeline_iam_role,
    module.sandbox_codepipeline_kms,
    module.codestar_connection
  ]
}

module "sandbox_codepipeline" {
  source = "../../modules/aws/codepipeline/sandbox"

  project_name = var.sandbox_project_name

  source_repo_owner  = var.source_repo_owner
  source_repo_name   = var.source_repo_name
  source_repo_branch = var.source_repo_branch

  IS_PULL_REQUEST = var.IS_PULL_REQUEST
  PR_NUMBER       = var.PR_NUMBER
  BRANCH_NAME     = var.BRANCH_NAME

  detect_changes = false

  stages = var.sandbox_stage_input

  region = var.region

  s3_bucket_name          = module.sandbox_s3_artifacts_bucket.bucket
  codepipeline_role_arn   = module.sandbox_codepipeline_iam_role.role_arn
  kms_key_arn             = module.sandbox_codepipeline_kms.arn
  codestar_connection_arn = module.codestar_connection.arn

  tags = var.tags

  depends_on = [module.sandbox_codebuild, module.sandbox_s3_artifacts_bucket]
}