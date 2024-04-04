resource "aws_iam_policy" "codepipeline_policy" {
  name        = "${var.project_name}-codepipeline-role-policy"
  description = "Policy to allow codepipeline to execute"
  tags        = var.tags
  policy      = data.aws_iam_policy_document.codepipeline_policy_document.json
}

resource "aws_iam_policy" "codepipeline_users_policy" {
  count = local.create_users_policy ? 1 : 0

  name        = "${var.project_name}-codepipeline-role-users-policy"
  description = "Policy to allow codepipeline to execute"
  tags        = var.tags
  policy      = data.aws_iam_policy_document.users_policy_document.json
}
