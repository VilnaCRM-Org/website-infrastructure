output "arn" {
  value       = data.aws_codestarconnections_connection.github_connection.id
  description = "The arn of the CodeStar connection"
}