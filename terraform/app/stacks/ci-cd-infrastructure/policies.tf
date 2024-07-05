module "ci_cd_infra_policies" {
  source = "../../modules/aws/iam/policies/codepipeline"

  policy_prefix = "${var.environment}-ci-cd-infra"

  project_name               = var.project_name
  website_project_name       = var.website_infra_project_name
  ci_cd_project_name         = var.ci_cd_infra_project_name
  ci_cd_website_project_name = var.ci_cd_website_project_name

  region      = var.region
  environment = var.environment

  tags = var.tags
}

module "website_infra_policies" {
  source = "../../modules/aws/iam/policies/website"

  project_name  = var.project_name
  policy_prefix = "${var.environment}-website-infra"
  region        = var.region
  environment   = var.environment
  domain_name   = var.website_url

  tags = var.tags
}

module "sandox_policies" {
  source = "../../modules/aws/iam/policies/sandbox"

  project_name  = var.sandbox_project_name
  policy_prefix = "${var.environment}-sandbox"
  region        = var.region
  environment   = var.environment

  tags = var.tags
}