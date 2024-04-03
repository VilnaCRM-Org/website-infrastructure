module "codepipeline_policies" {
  source = "../../modules/aws/iam/policies/website"

  project_name  = var.project_name
  policy_prefix = "${var.environment}-website-user"
  region        = var.region
  environment   = var.environment
  domain_name   = var.domain_name

  tags = var.tags
}

module "website_user" {
  source = "../../modules/aws/iam/users/website-deploy-user"

  policy_arns = module.codepipeline_policies.policy_arns

  tags = var.tags
}