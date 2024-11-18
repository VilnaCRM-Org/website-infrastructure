variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "region" {
  description = "Region for this project"
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

variable "codepipeline_iam_role_name" {
  description = "Name of the IAM role to be used by the project"
  type        = string
}

variable "tags" {
  description = "Tags to be attached to the IAM Role"
  type        = map(string)
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 Bucket"
  type        = string
}

variable "codestar_connection_arn" {
  description = "The ARN of the CodeStar connection"
  type        = string
}

variable "policy_arns" {
  type        = map(map(string))
  description = "Set of policies to attach to Role"
  default     = { value = {} }
}

variable "codepipeline_role_name_suffix" {
  description = "Suffix for the CodePipeline role name"
  type        = string
  default     = "-codepipeline-role"
}

variable "github_token_secret_name" {
  description = "Name of the GitHub token secret"
  type        = string
  default     = "github-token"
}