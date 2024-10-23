variable "secret_arn" {
  description = "The ARN of the GitHub token secret"
  type        = string
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