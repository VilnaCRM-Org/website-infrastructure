module "iam_roles" {
  source                  = "../../modules/aws/iam/roles/sandbox-deletion-role"
  project_name            = var.project_name
  environment             = var.environment
  region                  = var.region
  account_id              = data.aws_caller_identity.current.account_id
  codestar_connection_arn = module.codestar_connection.arn
  BRANCH_NAME             = var.BRANCH_NAME
}

module "s3_buckets" {
  source       = "../../modules/aws/s3/sandbox-deletion"
  project_name = var.project_name
  environment  = var.environment
  tags         = var.tags
}

module "codebuild_sandbox_deletion" {
  source             = "../../modules/aws/codebuild/sandbox-deletion"
  project_name       = local.project_name
  codebuild_role_arn = module.iam_roles.codebuild_role_arn
  source_repo_owner  = var.source_repo_owner
  source_repo_name   = var.source_repo_name
  buildspec_path     = var.buildspec_path
  BRANCH_NAME        = var.BRANCH_NAME
  region             = var.region
  logs_bucket_arn   = module.s3_buckets.codebuild_logs_bucket_arn
}

module "codepipeline_sandbox_deletion" {
  source                  = "../../modules/aws/codepipeline/sandbox-deletion"
  project_name            = local.project_name
  codepipeline_role_arn   = module.iam_roles.codepipeline_role_arn
  s3_bucket_name          = module.s3_buckets.codepipeline_bucket_name
  codestar_connection_arn = module.codestar_connection.arn
  source_repo_owner       = var.source_repo_owner
  source_repo_name        = var.source_repo_name
  source_repo_branch      = var.source_repo_branch
  codebuild_project_name  = module.codebuild_sandbox_deletion.codebuild_project_name
  region                  = var.region
}