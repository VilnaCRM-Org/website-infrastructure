variable "secret_arn" {
  description = "The ARN of the GitHub token secret"
  type        = string
}

variable "policy_name" {
  description = "Name of the IAM policy for GitHub token access"
  type        = string
  default     = "GitHubTokenSecretsAccessPolicy"
}