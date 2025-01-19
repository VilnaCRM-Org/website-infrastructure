resource "aws_iam_role_policy_attachment" "codepipeline_policy_role_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
  depends_on = [aws_iam_role.codepipeline_role, aws_iam_policy.codepipeline_policy]
}

resource "aws_iam_role_policy_attachment" "terraform_policy_role_attachments" {
  for_each = local.is_ci_cd_infra ? local.ci_cd_infra_arns : local.website_infra_arns

  role       = aws_iam_role.terraform_role.name
  policy_arn = each.value.arn
  depends_on = [aws_iam_role.terraform_role]
}

resource "aws_iam_role_policy_attachment" "terraform_ci_cd_policy_role_attachment" {
  count = local.is_ci_cd_infra ? 1 : 0

  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.terraform_ci_cd_policy[0].arn
  depends_on = [aws_iam_role.terraform_role, aws_iam_policy.terraform_ci_cd_policy[0]]
}


resource "aws_iam_role_policy_attachment" "terraform_iam_policy_role_attachment" {
  count = local.is_ci_cd_infra ? 1 : 0

  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.terraform_iam_policy[0].arn
  depends_on = [aws_iam_role.terraform_role, aws_iam_policy.terraform_iam_policy[0]]
}