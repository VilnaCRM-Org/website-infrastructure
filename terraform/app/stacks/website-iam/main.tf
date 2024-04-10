module "website_policies" {
  source = "../../modules/aws/iam/policies/website"

  project_name  = var.project_name
  policy_prefix = "${var.environment}-website-user"
  region        = var.region
  environment   = var.environment
  domain_name   = var.domain_name

  tags = var.tags
}

module "website_user_group" {
  source = "../../modules/aws/iam/user-groups/template"

  policy_arns = module.website_policies.policy_arns
  group_name  = var.website_user_group_name
  group_path  = var.website_user_group_path

  depends_on = [module.website_policies]
}

module "website_user" {
  source = "../../modules/aws/iam/users/template"

  user_name = "websiteUser"
  user_path = "/website-users/"

  group_membership_name = "website-group-membership"
  user_group_name       = module.website_user_group.name

  tags = var.tags

  depends_on = [module.website_user_group]
}