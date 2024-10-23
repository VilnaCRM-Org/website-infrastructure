variable "source_repo_owner" {
  description = "GitHub repository owner (organization or username). Must be 1-39 characters long, starting with alphanumeric character. Can contain hyphens but cannot end with hyphen."
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
  description = "The ARN of the IAM policy that grants permissions for GitHub token rotation. Format: arn:PARTITION:iam::ACCOUNT-ID:policy/PATH/POLICY-NAME"
  type        = string
  validation {
    condition     = can(regex("^arn:[a-zA-Z0-9-]+:iam::\\d{12}:policy/[a-zA-Z0-9+=,.@_/-]+$", var.policy_arn))
    error_message = "The policy_arn must be a valid AWS IAM policy ARN."
  }
}

variable "github_actions_role_name" {
  description = "Name of the IAM role to be used by the project"
  type        = string
  default     = "github-actions-role" 
}