module "github-oidc" {
  source               = "git::https://github.com/terraform-module/terraform-aws-github-oidc-provider.git?ref=65f314a780b489f56630256adf6c021315877811"
  create_oidc_provider = true
  create_oidc_role     = true
  role_name            = "${var.project_name}-github-oidc-codepipeline-role"

  repositories              = ["${var.source_repo_owner}/${var.source_repo_name}"]
  oidc_role_attach_policies = [aws_iam_policy.codepipeline_policy.arn]

  tags = var.tags
}