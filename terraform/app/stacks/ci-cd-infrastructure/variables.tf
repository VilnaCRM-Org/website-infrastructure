variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "environment" {
  description = "Environment for this project"
  type        = string
}

variable "source_repo_owner" {
  description = "Source repo owner of the GitHub repository"
  type        = string
}

variable "source_repo_name" {
  description = "Source repo name of the repository"
  type        = string
}

variable "source_repo_branch" {
  description = "Default branch in the Source repo for which CodePipeline needs to be configured"
  type        = string
}

variable "github_connection_name" {
  description = "Name of the CodeStar connection"
  type        = string
}

variable "create_new_role" {
  description = "Whether to create a new IAM Role. Values are true or false. Defaulted to true always."
  type        = bool
  default     = true
}

variable "codepipeline_iam_role_name" {
  description = "Name of the IAM role to be used by the Codepipeline"
  type        = string
  default     = "codepipeline-role"
}

variable "stage_input" {
  description = "List of Map containing information about the stages of the CodePipeline"
  type        = list(map(any))
}

variable "tags" {
  description = "Tags to be associated with the S3 bucket"
  type        = map(any)
}