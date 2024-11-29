output "role_arn" {
  description = "ARN of the IAM role used by GitHub Actions to trigger CodePipeline"
  value       = aws_iam_role.codepipeline_trigger_role.arn
}