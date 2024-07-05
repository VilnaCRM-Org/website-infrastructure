output "id" {
  value       = [for project in aws_codebuild_project.terraform_codebuild_project : project.id]
  description = "List of IDs of the CodeBuild projects"
}

output "name" {
  value       = [for project in aws_codebuild_project.terraform_codebuild_project : project.name]
  description = "List of Names of the CodeBuild projects"
}

output "arn" {
  value       = [for project in aws_codebuild_project.terraform_codebuild_project : project.arn]
  description = "List of ARNs of the CodeBuild projects"
}
