resource "aws_iam_user" "admin_user" {
  #checkov:skip=CKV_AWS_273: SSO is not an option
  name = var.user_name
  path = var.user_path

  tags = var.tags
}

resource "aws_iam_group_membership" "admin_groups_membership" {
  for_each = var.groups
  name     = "${each.value.name}-membership"

  users = [
    aws_iam_user.admin_user.name
  ]
  #checkov:skip=CKV2_AWS_14: Will be added at the end of stack execution
  #checkov:skip=CKV2_AWS_21: Will be added at the end of stack execution
  group = each.value.name
}
