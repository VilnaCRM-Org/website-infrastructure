output "codepipeline_role_arn" {
  description = "The ARN of the IAM role used by CodePipeline for sandbox deletion"
  value       = aws_iam_role.codepipeline_role_sandbox.arn
  sensitive   = true
}

output "codebuild_role_arn" {
  description = "The ARN of the IAM role used by CodeBuild for sandbox deletion"
  value       = aws_iam_role.codebuild_role_sandbox.arn
  sensitive   = true
}