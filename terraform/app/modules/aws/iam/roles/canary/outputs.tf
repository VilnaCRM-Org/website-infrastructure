output "arn" {
  value       = aws_iam_role.canary_role.arn
  description = "The ARN of the IAM Role"
}