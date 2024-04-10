module "frontend_policies" {
  source = "../../modules/aws/iam/policies/frontend"

  policy_prefix = "${var.environment}-frontend-group"
  region        = var.region
  environment   = var.environment

  tags = var.tags
}

module "frontend_user_group" {
  source = "../../modules/aws/iam/user-groups/template"

  policy_arns = module.frontend_policies.policy_arns
  group_name  = var.frontend_user_group_name
  group_path  = var.frontend_user_group_path

  depends_on = [module.frontend_policies]
}

module "devops_policies" {
  source = "../../modules/aws/iam/policies/devops"

  policy_prefix = "${var.environment}-devops-group"
  region        = var.region
  environment   = var.environment

  tags = var.tags
}

module "devops_user_group" {
  source = "../../modules/aws/iam/user-groups/template"

  policy_arns = module.devops_policies.policy_arns
  group_name  = var.devops_user_group_name
  group_path  = var.devops_user_group_path

  depends_on = [module.devops_policies]
}

module "backend_policies" {
  source = "../../modules/aws/iam/policies/backend"

  policy_prefix = "${var.environment}-backend-group"
  region        = var.region
  environment   = var.environment

  tags = var.tags
}

module "backend_user_group" {
  source = "../../modules/aws/iam/user-groups/template"

  policy_arns = module.backend_policies.policy_arns
  group_name  = var.backend_user_group_name
  group_path  = var.backend_user_group_path

  depends_on = [module.backend_policies]
}

module "qa_policies" {
  source = "../../modules/aws/iam/policies/qa"

  policy_prefix = "${var.environment}-qa-group"
  region        = var.region
  environment   = var.environment

  tags = var.tags
}

module "qa_user_group" {
  source = "../../modules/aws/iam/user-groups/template"

  policy_arns = module.qa_policies.policy_arns
  group_name  = var.qa_user_group_name
  group_path  = var.qa_user_group_path

  depends_on = [module.qa_policies]
}

module "admin_policies" {
  source = "../../modules/aws/iam/policies/admin"

  policy_prefix = "${var.environment}-admin-group"
  region        = var.region
  environment   = var.environment

  tags = var.tags
}

module "admin_user_group" {
  source = "../../modules/aws/iam/user-groups/template"

  policy_arns = module.admin_policies.policy_arns
  group_name  = var.admin_user_group_name
  group_path  = var.admin_user_group_path

  depends_on = [module.admin_policies]
}

module "admin_user" {
  source = "../../modules/aws/iam/users/admin"

  user_name = "adminUser"
  user_path = var.admin_user_group_path
  groups    = local.group_names

  tags = var.tags

  depends_on = [
    module.frontend_user_group,
    module.devops_user_group,
    module.backend_user_group,
    module.qa_user_group,
    module.admin_user_group
  ]
}