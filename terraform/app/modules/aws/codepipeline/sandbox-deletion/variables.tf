variable "project_name" { 
  description = "The name of the project used for resource naming"
  type        = string 
}

variable "codepipeline_role_arn" {
  description = "ARN of the IAM role for CodePipeline execution"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for pipeline artifacts"
  type        = string
}

variable "codestar_connection_arn" {
  description = "ARN of the CodeStar connection for GitHub access"
  type        = string
}

variable "source_repo_owner" {
  description = "GitHub repository owner"
  type        = string
}

variable "source_repo_name" {
  description = "Name of the GitHub repository"
  type        = string
}

variable "source_repo_branch" {
  description = "Branch name to track in the GitHub repository"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]+$", var.source_repo_branch))
    error_message = "Branch name must contain only alphanumeric characters, underscores, dots, and hyphens."
  }
}

variable "codebuild_project_name" {
  description = "Name of the CodeBuild project for sandbox deletion"
  type        = string
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  validation {
    condition     = can(regex("^[a-z]{2}-(gov-)?[a-z]+-\\d$", var.region))
    error_message = "Must be a valid AWS region name (e.g., us-east-1, eu-west-1)."
  }
}