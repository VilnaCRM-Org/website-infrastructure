resource "aws_iam_user" "user" {
  #checkov:skip=CKV_AWS_273: SSO is not an option
  name = var.user_name
  path = var.user_path

  tags = var.tags
}

resource "aws_iam_group_membership" "group_membership" {
  name = var.group_membership_name

  users = [
    aws_iam_user.user.name
  ]
  #checkov:skip=CKV2_AWS_14: Will be added at the end of stack execution
  #checkov:skip=CKV2_AWS_21: Will be added at the end of stack execution
  group = var.user_group_name
}