resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = var.policy_arn
}