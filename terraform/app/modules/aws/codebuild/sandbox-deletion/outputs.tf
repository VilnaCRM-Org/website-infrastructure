output "codebuild_project_name" {
  value = aws_codebuild_project.sandbox_deletion.name
}

output "codebuild_project_arn" {
  value = aws_codebuild_project.sandbox_deletion.arn
}