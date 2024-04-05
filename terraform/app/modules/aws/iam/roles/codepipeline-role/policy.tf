resource "aws_iam_policy" "codepipeline_policy" {
  name        = "${var.project_name}-codepipeline-role-policy"
  description = "Policy to allow codepipeline to execute"
  tags        = var.tags
  policy      = data.aws_iam_policy_document.codepipeline_policy_document.json
}

resource "aws_iam_policy" "terraform_ci_cd_policy" {
  count = local.is_ci_cd_infra ? 1 : 0

  name        = "${var.project_name}-terraform-role-ci-cd-policy"
  description = "Policy to allow actions on CI/CD Infrastructure"
  tags        = var.tags
  policy      = data.aws_iam_policy_document.terraform_policy_document.json
}