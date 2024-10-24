variable "secret_arn" {
  description = "The ARN of the GitHub token secret in AWS Secrets Manager (format: arn:aws:secretsmanager:REGION:ACCOUNT:secret:NAME)"
  type        = string
  sensitive   = true
  validation {
    condition     = can(regex("^arn:aws:secretsmanager:[a-z0-9-]+:[0-9]{12}:secret:.+$", var.secret_arn))
    error_message = "The secret_arn value must be a valid AWS Secrets Manager ARN"
  }
}

variable "policy_name" {
  description = "GitHub repository name. Must be 1-100 characters long and can contain alphanumeric characters, underscores, dots, and hyphens."
  type        = string
  default     = "GitHubTokenSecretsAccessPolicy"
  validation {
    condition     = can(regex("^[\\w+=,.@-]{1,128}$", var.policy_name))
    error_message = "Policy name must be between 1 and 128 characters, and can include alphanumeric characters and +=,.@-"
  }
}