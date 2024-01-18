output "arn" {
  value       = aws_codestarconnections_connection.github_connection.arn
  description = "The arn of the CodePipeline"
}
