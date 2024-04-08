module "frontend_policies" {
  source = "../../modules/aws/iam/policies/frontend"

  policy_prefix = "${var.environment}-frontend"
  region        = var.region
  environment   = var.environment

  tags = var.tags
}

module "frontend_users_group" {
  source = "../../modules/aws/iam/user-groups/template"

  policy_arns = module.frontend_policies.policy_arns
  group_name  = var.frontend_user_group_name
  group_path  = var.frontend_user_group_path

  depends_on = [module.frontend_policies]
}