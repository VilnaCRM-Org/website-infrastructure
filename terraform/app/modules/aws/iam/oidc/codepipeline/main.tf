module "github_oidc" {
  source               = "git::https://github.com/terraform-module/terraform-aws-github-oidc-provider.git?ref=65f314a780b489f56630256adf6c021315877811"
  create_oidc_provider = true
  create_oidc_role     = true
  role_name            = "${var.project_name}-github-oidc-codepipeline-role"

  repositories              = ["${var.source_repo_owner}/${var.source_repo_name}"]
  oidc_role_attach_policies = [aws_iam_policy.codepipeline_policy.arn]

  tags = var.tags
}

resource "github_actions_secret" "aws_codepipeline_role_arn" {
  #checkov:skip=CKV_GIT_4: It is encypted in any case - https://github.com/bridgecrewio/checkov/issues/2374
  repository      = var.source_repo_name
  secret_name     = "AWS_CODEPIPELINE_ROLE_ARN"
  plaintext_value = module.github_oidc.oidc_role

  depends_on = [module.github_oidc]
}

resource "github_actions_secret" "aws_codepipeline_name" {
  repository      = var.source_repo_name
  secret_name     = "AWS_WEBSITE_CODEPIPELINE_NAME"
  plaintext_value = var.ci_cd_website_codepipeline_name
}

resource "github_actions_secret" "aws_codepipeline_name" {
  repository      = var.source_repo_name
  secret_name     = "AWS_SANDBOX_CODEPIPELINE_NAME"
  plaintext_value = var.sandbox_codepipeline_name
}