output "github_token_secret_arn" {
  value       = module.github_token_secret.secret_arn
  description = "ARN of the GitHub token secret"
}

output "website_infra_pipeline_name" {
  value       = module.website_infra_codepipeline.name
  description = "Website pipeline started after the CI/CD infrastructure apply"
}
