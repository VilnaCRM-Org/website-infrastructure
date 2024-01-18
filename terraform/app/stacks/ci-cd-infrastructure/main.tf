module "s3_artifacts_bucket" {
  source       = "../../modules/aws/s3"
  project_name = var.project_name

  kms_key_arn           = module.codepipeline_kms.arn
  codepipeline_role_arn = module.codepipeline_iam_role.role_arn

  tags = var.tags
}

module "codepipeline_kms" {
  source                = "../../modules/aws/kms"
  codepipeline_role_arn = module.codepipeline_iam_role.role_arn

  tags = var.tags
}

module "codestar_connection" {
  source       = "../../modules/aws/codestar"
  github_connection_name = var.github_connection_name

  tags = var.tags
}

module "codepipeline_iam_role" {
  source = "../../modules/aws/iam-role"

  project_name               = var.project_name
  create_new_role            = var.create_new_role
  codepipeline_iam_role_name = var.create_new_role == true ? "${var.project_name}-codepipeline-role" : var.codepipeline_iam_role_name

  kms_key_arn             = module.codepipeline_kms.arn
  s3_bucket_arn           = module.s3_artifacts_bucket.arn
  codestar_connection_arn = module.codestar_connection.arn

  tags = var.tags
}

module "codepipeline_terraform" {
  source = "../../modules/aws/codepipeline"

  project_name       = var.project_name
  source_repo_owner  = var.source_repo_owner
  source_repo_name   = var.source_repo_name
  source_repo_branch = var.source_repo_branch

  stages = var.stage_input

  s3_bucket_name          = module.s3_artifacts_bucket.bucket
  codepipeline_role_arn   = module.codepipeline_iam_role.role_arn
  kms_key_arn             = module.codepipeline_kms.arn
  codestar_connection_arn = module.codestar_connection.arn

  tags = var.tags

  depends_on = [
    module.codestar_connection,
    module.codepipeline_iam_role,
    module.s3_artifacts_bucket
  ]
}