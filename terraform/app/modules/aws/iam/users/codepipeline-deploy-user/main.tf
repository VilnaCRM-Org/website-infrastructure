resource "aws_iam_group" "codepipeline_users" {
  name = "codepipeline-users"
  path = "/codepipeline-users/"
}

resource "aws_iam_user" "codepipeline_user" {
  #checkov:skip=CKV_AWS_273: SSO is not an option
  name = "codepipelineUser"
  path = "/codepipeline-users/"

  tags = var.tags
}

resource "aws_iam_group_membership" "codepipeline_group_membership" {
  name = "codepipeline-group-membership"

  users = [
    aws_iam_user.codepipeline_user.name
  ]

  group = aws_iam_group.codepipeline_users.name
}

resource "aws_iam_group_policy_attachment" "policy_attachments" {
  for_each = var.policy_arns

  group      = aws_iam_group.codepipeline_users.name
  policy_arn = each.value.arn
  depends_on = [aws_iam_group.codepipeline_users]
}