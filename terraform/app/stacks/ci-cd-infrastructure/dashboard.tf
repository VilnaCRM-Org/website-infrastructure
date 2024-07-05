module "infrastructure_dashboard" {
  source = "../../modules/aws/cloudwatch/infrastructure-dashboard"

  website_project_name       = var.website_infra_project_name
  ci_cd_project_name         = var.ci_cd_infra_project_name
  ci_cd_website_project_name = var.ci_cd_website_project_name


  region      = var.region
  environment = var.environment
}