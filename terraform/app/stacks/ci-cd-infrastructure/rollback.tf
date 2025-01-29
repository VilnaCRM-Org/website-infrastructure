module "codebuild_cloudfront_rollback_iam_role" {
  source = "../../modules/aws/iam/roles/rollback"

  project_name = var.ci_cd_website_project_name

  codebuild_iam_role_name = "${var.ci_cd_website_project_name}-codebuild-rollback-role"

  source_repo_owner = var.source_repo_owner
  source_repo_name  = var.source_repo_name

  region      = var.region
  environment = var.environment

  codestar_connection_arn = module.codestar_connection.arn

  tags = var.tags
}

module "codebuild_cloudfront_rollback" {
  source = "../../modules/aws/codebuild/project"

  project_name = "${var.ci_cd_website_project_name}-rollback"

  region      = var.region
  environment = var.environment

  build_configuration = local.amazonlinux2_based_build
  env_variables       = local.codebuild_cloudfront_rollback_project_env_variables

  source_configuration = local.codebuild_rollback_source_configuration

  role_arn    = module.codebuild_cloudfront_rollback_iam_role.arn

  tags = var.tags

  depends_on = [
    module.codebuild_cloudfront_rollback_iam_role,
    module.codestar_connection
  ]
}