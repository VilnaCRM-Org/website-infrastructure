variable "secret_arn" {
  description = "The ARN of the GitHub token secret in AWS Secrets Manager (format: arn:aws:secretsmanager:REGION:ACCOUNT:secret:NAME)"
  type        = string
  sensitive   = true
}

variable "policy_name" {
  description = "GitHub repository name. Must be 1-100 characters long and can contain alphanumeric characters, underscores, dots, and hyphens."
  type        = string
  default     = "GitHubTokenSecretsAccessPolicy"
}