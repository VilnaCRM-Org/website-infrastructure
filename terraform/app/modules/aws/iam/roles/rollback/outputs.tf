output "arn" {
  value       = aws_iam_role.codebuild_role.arn
  description = "The ARN of the IAM Role"
}
