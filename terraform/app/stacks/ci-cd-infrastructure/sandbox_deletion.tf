module "iam_roles" {
  source                  = "../../modules/aws/iam/roles/sandbox-deletion-role"
  project_name            = var.project_name
  environment             = var.environment
  region                  = var.region
  account_id              = data.aws_caller_identity.current.account_id
  codestar_connection_arn = module.codestar_connection.arn
  BRANCH_NAME             = var.BRANCH_NAME
  kms_key_arn             = module.sandbox_deletion_codepipeline_kms.arn
}

module "s3_buckets" {
  source       = "../../modules/aws/s3/sandbox-deletion"
  project_name = var.project_name
  environment  = var.environment
  tags         = var.tags
}

module "sandbox_deletion_codepipeline_kms" {
  source = "../../modules/aws/kms"

  codepipeline_role_arn = "arn:aws:iam::${local.account_id}:role/${local.project_name}-codepipeline-role"

  tags = var.tags
}

module "codebuild_sandbox_deletion" {
  source         = "../../modules/aws/codebuild/stages"
  project_name   = local.project_name
  role_arn       = module.iam_roles.codebuild_role_arn
  build_projects = local.sandbox_delete_projects
  kms_key_arn    = module.sandbox_deletion_codepipeline_kms.arn
  s3_bucket_name = module.s3_buckets.codebuild_logs_bucket_name
  environment    = var.environment
  region         = var.region
  tags           = var.tags

  depends_on = [module.iam_roles, module.s3_buckets]
}

module "codepipeline_sandbox_deletion" {
  source = "../../modules/aws/codepipeline/sandbox"

  codepipeline_name = "${local.project_name}-deletion"

  project_name = local.project_name

  source_repo_owner  = var.source_repo_owner
  source_repo_name   = var.source_repo_name
  source_repo_branch = var.source_repo_branch

  PR_NUMBER       = var.PR_NUMBER
  BRANCH_NAME     = var.BRANCH_NAME
  IS_PULL_REQUEST = var.IS_PULL_REQUEST

  detect_changes = false

  stages = var.sandbox_deletion_stage_input

  region = local.region

  codepipeline_role_arn   = module.iam_roles.codepipeline_role_arn
  s3_bucket_name          = module.s3_buckets.codepipeline_bucket_name
  codestar_connection_arn = module.codestar_connection.arn
  kms_key_arn             = module.sandbox_deletion_codepipeline_kms.arn

  tags = var.tags

  depends_on = [module.s3_buckets, module.codebuild_sandbox_deletion]
}