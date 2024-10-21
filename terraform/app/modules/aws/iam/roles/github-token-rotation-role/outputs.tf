output "role_arn" {
  description = "The ARN of the IAM role used for GitHub Actions token rotation."
  value = aws_iam_role.github_actions_role.arn
}