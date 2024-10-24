variable "source_repo_owner" {
  description = "GitHub repository owner (organization or username). Must be 1-39 characters long, starting with alphanumeric character. Can contain hyphens but cannot end with hyphen."
  type        = string
}

variable "source_repo_name" {
  description = "GitHub repository name"
  type        = string
}

variable "policy_arn" {
  description = "The ARN of the IAM policy that grants permissions for GitHub token rotation. Format: arn:PARTITION:iam::ACCOUNT-ID:policy/PATH/POLICY-NAME"
  type        = string
}

variable "github_actions_role_name" {
  description = "Name of the IAM role to be used by the project"
  type        = string
  default     = "github-actions-role"
}