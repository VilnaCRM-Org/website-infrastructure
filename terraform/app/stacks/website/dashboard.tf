module "website_dashboard" {
  source = "../../modules/aws/cloudwatch/website-dashboard"

  project_name = var.project_name
  region       = var.region
  environment  = var.environment

  web_acl_name       = module.cloudfront.waf_web_acl_name
  waf_log_group_name = module.cloudfront.waf_log_group_name

  depends_on = [module.cloudfront]
}