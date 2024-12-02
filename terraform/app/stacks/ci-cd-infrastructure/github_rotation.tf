module "github_token_secret" {
  source                   = "../../modules/aws/secrets"
  github_token_secret_name = var.github_token_secret_name
}

module "github_token_policy" {
  source = "../../modules/aws/iam/policies/github-token"
}

module "github_actions_role" {
  source            = "../../modules/aws/iam/roles/github-token-rotation-role"
  source_repo_owner = var.source_repo_owner
  source_repo_name  = var.source_repo_name
  policy_arn        = module.github_token_policy.policy_arn
}