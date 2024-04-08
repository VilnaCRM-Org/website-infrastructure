resource "aws_iam_user" "website_user" {
  #checkov:skip=CKV_AWS_273: SSO is not an option
  name = "websiteUser"
  path = "/website-users/"

  tags = var.tags
}

resource "aws_iam_group_membership" "website_group_membership" {
  name = "website-group-membership"

  users = [
    aws_iam_user.website_user.name
  ]

  group = var.website_user_group_name
}