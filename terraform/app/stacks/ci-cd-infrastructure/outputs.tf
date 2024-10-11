output "github_token_secret_arn" {
  value       = module.github_token_secret.aws_secretsmanager_secret.github_token.arn
  description = "ARN of the GitHub token secret"
}