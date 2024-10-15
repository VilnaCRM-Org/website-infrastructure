variable "source_repo_owner" {
  description = "GitHub repository owner"
  type        = string
}

variable "source_repo_name" {
  description = "GitHub repository name"
  type        = string
}

variable "policy_arn" {
  description = "The ARN of the GitHub token access policy"
  type        = string
}