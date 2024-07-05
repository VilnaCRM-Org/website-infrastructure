resource "aws_iam_group" "user_group" {
  name = var.group_name
  path = var.group_path
}

resource "aws_iam_group_policy_attachment" "policy_attachments" {
  for_each = var.policy_arns

  group      = aws_iam_group.user_group.name
  policy_arn = each.value.arn
  depends_on = [aws_iam_group.user_group]
}