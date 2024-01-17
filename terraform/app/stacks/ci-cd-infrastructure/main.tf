module "s3_artifacts_bucket" {
  source                = "../../modules/aws/s3"
  project_name          = var.project_name
  kms_key_arn           = module.codepipeline_kms.arn
  codepipeline_role_arn = module.codepipeline_iam_role.role_arn

  tags = var.tags
}

module "codepipeline_kms" {
  source                = "../../modules/aws/kms"
  codepipeline_role_arn = module.codepipeline_iam_role.role_arn

  tags = var.tags
}

module "codepipeline_iam_role" {
  source                     = "../../modules/aws/iam-role"
  project_name               = var.project_name
  create_new_role            = var.create_new_role
  codepipeline_iam_role_name = var.create_new_role == true ? "${var.project_name}-codepipeline-role" : var.codepipeline_iam_role_name

  kms_key_arn                = module.codepipeline_kms.arn
  s3_bucket_arn              = module.s3_artifacts_bucket.arn

  tags = var.tags
}

# module "codepipeline_terraform" {
#   source = "../../modules/aws/codepipeline"

#   project_name       = var.project_name
#   source_repo_name   = var.source_repo_name
#   source_repo_branch = var.source_repo_branch
#   github_oauthtoken  = var.github_oauthtoken
#   // stages                = var.stage_input

#   s3_bucket_name        = module.s3_artifacts_bucket.bucket
#   codepipeline_role_arn = module.codepipeline_iam_role.role_arn
#   kms_key_arn           = module.codepipeline_kms.arn

#   tags = var.tags

#   depends_on = [
#     //module.codebuild_terraform,
#     module.s3_artifacts_bucket
#   ]
# }