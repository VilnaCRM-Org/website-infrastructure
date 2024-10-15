output "github_token_secret_arn" {
  value       = module.github_token_secret.secret_arn
  description = "ARN of the GitHub token secret"
}