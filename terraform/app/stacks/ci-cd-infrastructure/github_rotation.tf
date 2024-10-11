module "github_token_secret" {
  source = "../../modules/aws/secrets/github_token"
}

module "github_token_policy" {
  source = "../../modules/aws/iam/policies/github_token"
}

module "codepipeline_role_policy_attachment" {
  source = "../../modules/aws/iam/roles/codepipeline"
}