resource "aws_iam_user" "codepipeline_user" {
  name = "${var.project_name}-codepipeline-user"

  tags = var.tags
}

resource "aws_iam_user_policy" "codepipeline_execute_policy" {
  name   = "test"
  user   = aws_iam_user.codepipeline_user.name
  policy = data.aws_iam_policy_document.codepipeline_execute_policy_doc.json
}

resource "aws_iam_access_key" "codepipeline_user_iam_access_key" {
  user = aws_iam_user.codepipeline_user.name
}

