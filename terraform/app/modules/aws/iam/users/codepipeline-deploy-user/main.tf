resource "aws_iam_group" "codepipeline_users" {
  name = "codepipeline-users"
  path = "/codepipeline-users/"
}

resource "aws_iam_user" "codepipeline_user" {
  #checkov:skip=CKV_AWS_273: SSO is not an option
  name = "codepipeline-user"
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