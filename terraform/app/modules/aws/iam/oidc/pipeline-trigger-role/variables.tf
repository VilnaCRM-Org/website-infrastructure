variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "github_owner" {
  description = "GitHub organization or user"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "branch" {
  description = "Branch to trigger the pipeline"
  type        = string
  default     = "main"
}

variable "pipeline_arn" {
  description = "ARN of the CodePipeline to trigger"
  type        = string
}