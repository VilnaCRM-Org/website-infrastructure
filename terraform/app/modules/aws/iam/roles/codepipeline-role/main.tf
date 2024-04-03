resource "aws_iam_role" "codepipeline_role" {
  name               = var.codepipeline_iam_role_name
  tags               = var.tags
  assume_role_policy = data.aws_iam_policy_document.codepipeline_role_document.json
  path               = "/"
}

resource "aws_iam_policy" "codepipeline_policy" {
  name        = "${var.project_name}-codepipeline-role-policy"
  description = "Policy to allow codepipeline to execute"
  tags        = var.tags
  policy      = data.aws_iam_policy_document.codepipeline_policy_document.json
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy_role_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
  depends_on = [aws_iam_role.codepipeline_role, aws_iam_policy.codepipeline_policy]
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy_role_attachments" {
  for_each = var.policy_arns

  role      = aws_iam_role.codepipeline_role.name
  policy_arn = each.value.arn
  depends_on = [aws_iam_role.codepipeline_role]
}