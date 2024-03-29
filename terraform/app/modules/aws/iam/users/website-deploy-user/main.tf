resource "aws_iam_group" "website_users" {
  name = "website-users"
  path = "/website-users/"
}

resource "aws_iam_user" "website_user" {
  #checkov:skip=CKV_AWS_273: SSO is not an option
  name = "website-user"
  path = "/website-users/"

  tags = var.tags
}

resource "aws_iam_group_membership" "website_group_membership" {
  name = "website-group-membership"

  users = [
    aws_iam_user.website_user.name
  ]

  group = aws_iam_group.website_users.name
}