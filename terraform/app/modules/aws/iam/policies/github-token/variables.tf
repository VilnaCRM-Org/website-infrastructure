variable "secret_arn" {
  description = "The ARN of the GitHub token secret in AWS Secrets Manager (format: arn:aws:secretsmanager:REGION:ACCOUNT:secret:NAME)"
  type        = string
  sensitive   = true
}

variable "policy_name" {
  description = "Name of the IAM policy for GitHub token access."
  type        = string
  default     = "GitHubTokenSecretsAccessPolicy"
}