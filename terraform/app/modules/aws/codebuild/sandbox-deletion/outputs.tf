output "codebuild_project_name" {
  description = "The name of the CodeBuild project for sandbox deletion"
  value       = aws_codebuild_project.sandbox_deletion.name
}

output "codebuild_project_arn" {
  description = "The ARN of the CodeBuild project for sandbox deletion"
  value       = aws_codebuild_project.sandbox_deletion.arn
}