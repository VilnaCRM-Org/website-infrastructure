module "codepipeline_policies" {
  source = "../../modules/aws/iam/policies/codepipeline"

  policy_prefix        = "${var.environment}-codepipeline-user"
  website_project_name = var.website_project_name
  ci_cd_project_name   = var.ci_cd_project_name
  region               = var.region
  environment          = var.environment

  tags = var.tags
}

module "codepipeline_user" {
  source = "../../modules/aws/iam/users/codepipeline-deploy-user"

  policy_arns = module.codepipeline_policies.policy_arns

  tags = var.tags

  depends_on = [module.codepipeline_policies]
}