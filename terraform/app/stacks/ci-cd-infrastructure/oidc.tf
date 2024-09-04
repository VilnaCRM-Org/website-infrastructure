module "oidc_role" {
  source = "../../modules/aws/iam/oidc/codepipeline"

  project_name      = var.ci_cd_website_project_name
  source_repo_owner = var.source_repo_owner
  source_repo_name  = var.website_content_repo_name

  ci_cd_website_codepipeline_arn  = module.ci_cd_website_codepipeline.arn
  ci_cd_website_codepipeline_name = module.ci_cd_website_codepipeline.name

  sandbox_codepipeline_arn  = module.sandbox_codepipeline.arn
  sandbox_codepipeline_name = module.sandbox_codepipeline.name

  tags = var.tags

  environment = var.environment

  depends_on = [module.ci_cd_website_codepipeline, module.sandbox_codepipeline]
}