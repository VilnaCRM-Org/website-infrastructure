module "codepipeline_policies" {
  source = "../../modules/aws/iam/policies/codepipeline"

  policy_prefix        = "${var.environment}-codepipeline-user"
  website_project_name = var.website_project_name
  ci_cd_project_name   = var.ci_cd_project_name
  region               = var.region
  environment          = var.environment

  tags = var.tags
}

module "codepipeline_user_group" {
  source = "../../modules/aws/iam/user-groups/template"

  policy_arns = module.codepipeline_policies.policy_arns
  group_name  = var.codepipeline_user_group_name
  group_path  = var.codepipeline_user_group_path

  depends_on = [module.codepipeline_policies]
}

module "codepipeline_user" {
  source = "../../modules/aws/iam/users/template"

  user_name = "codepipelineUser"
  user_path = "/codepipeline-users/"

  group_membership_name = "codepipeline-group-membership"
  user_group_name       = module.codepipeline_user_group.name

  tags = var.tags

  depends_on = [module.codepipeline_user_group]
}