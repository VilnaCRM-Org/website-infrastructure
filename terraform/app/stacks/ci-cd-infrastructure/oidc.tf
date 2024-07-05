module "oidc_role" {
  source = "../../modules/aws/iam/oidc/codepipeline"

  project_name      = var.ci_cd_website_project_name
  source_repo_owner = var.source_repo_owner
  source_repo_name  = var.website_content_repo_name

  environment = var.environment

  ci_cd_website_codepipeline_arn  = module.ci_cd_website_codepipeline.arn
  ci_cd_website_codepipeline_name = module.ci_cd_website_codepipeline.name

  tags = var.tags

  depends_on = [module.ci_cd_website_codepipeline]
}