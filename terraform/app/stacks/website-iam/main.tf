module "website_user" {
  source = "../../modules/aws/iam/users/website-deploy-user"

  project_name = var.project_name
  region       = var.region
  environment  = var.environment
  domain_name  = var.domain_name
  
  tags         = var.tags
}