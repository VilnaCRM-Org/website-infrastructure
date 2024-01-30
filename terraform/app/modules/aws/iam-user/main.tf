resource "aws_iam_user" "codepipeline_user" {
  name = "${var.project_name}-codepipeline-user"
  #checkov:skip=CKV_AWS_273: Necessary for triggering pipeline
  tags = var.tags
}

resource "aws_iam_user_policy" "codepipeline_execute_policy" {
  name = "${var.project_name}-exec-policy"
  #checkov:skip=CKV_AWS_40: Necessary for triggering pipeline
  user   = aws_iam_user.codepipeline_user.name
  policy = data.aws_iam_policy_document.codepipeline_execute_policy_doc.json
}

resource "aws_iam_access_key" "codepipeline_user_iam_access_key" {
  user = aws_iam_user.codepipeline_user.name
}

