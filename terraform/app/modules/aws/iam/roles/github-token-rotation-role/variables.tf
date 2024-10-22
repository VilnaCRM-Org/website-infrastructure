variable "source_repo_owner" {
  description = "GitHub repository owner"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9](?:[a-zA-Z0-9]|-(?=[a-zA-Z0-9])){0,38}$", var.source_repo_owner))
    error_message = "The source_repo_owner must be a valid GitHub username or organization name."
  }
}

variable "source_repo_name" {
  description = "GitHub repository name"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]{1,100}$", var.source_repo_name))
    error_message = "The source_repo_name must be a valid GitHub repository name."
  }
}

variable "policy_arn" {
  description = "The ARN of the GitHub token access policy"
  type        = string
  validation {
    condition     = can(regex("^arn:aws:iam::\\d{12}:policy/", var.policy_arn))
    error_message = "The policy_arn must be a valid AWS IAM policy ARN."
  }
}