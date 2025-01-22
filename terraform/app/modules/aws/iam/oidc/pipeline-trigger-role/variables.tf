variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "github_owner" {
  description = "GitHub organization or username that owns the repository (e.g., 'VilnaCRM-Org')"
  type        = string
}

variable "github_repo" {
  description = "Name of the GitHub repository without owner prefix (e.g., 'website-infrastructure')"
  type        = string
}

variable "website_repo" {
  description = "Name of the GitHub repository without owner prefix (e.g., 'website')"
  type        = string
}

variable "branch" {
  description = "Branch to trigger the pipeline (defaults to 'main')"
  type        = string
  default     = "main"
}

variable "pipeline_arn" {
  description = "ARN of the CodePipeline to trigger (e.g., 'arn:aws:codepipeline:region:account:pipeline-name')"
  type        = string
  validation {
    condition     = can(regex("^arn:aws:codepipeline:[a-z0-9-]+:\\d{12}:.+$", var.pipeline_arn))
    error_message = "Pipeline ARN must be a valid AWS CodePipeline ARN."
  }
}