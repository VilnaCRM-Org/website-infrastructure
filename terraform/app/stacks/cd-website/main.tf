module "s3_artifacts_bucket" {
  source                = "../../../app/modules/aws/s3"
  project_name          = var.project_name
  kms_key_arn           = module.codepipeline_kms.arn
  codepipeline_role_arn = module.codepipeline_iam_role.role_arn
  tags = {
    Project_Name = var.project_name
    Environment  = var.environment
  }
}

module "codepipeline_kms" {
  source                = "../../../app/modules/aws/kms"
  codepipeline_role_arn = module.codepipeline_iam_role.role_arn
  tags = {
    Project_Name = var.project_name
    Environment  = var.environment
  }

}

module "codepipeline_iam_role" {
  source                     = "../../../app/modules/aws/iam-role"
  project_name               = var.project_name
  create_new_role            = var.create_new_role
  codepipeline_iam_role_name = var.create_new_role == true ? "${var.project_name}-codepipeline-role" : var.codepipeline_iam_role_name
  source_repository_name     = var.source_repo_name
  kms_key_arn                = module.codepipeline_kms.arn
  s3_bucket_arn              = module.s3_artifacts_bucket.arn
  tags = {
    Project_Name = var.project_name
    Environment  = var.environment
  }
}