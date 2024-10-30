variable "project_name" {
  description = "Name of the CodeBuild project for sandbox deletion"
  type = string
  validation {
    condition     = length(var.project_name) > 0
    error_message = "Project name cannot be empty"
  }
}

variable "codebuild_role_arn" {
  description = "ARN of the IAM role to be used by CodeBuild"
  type = string
  validation {
    condition     = can(regex("^arn:aws:iam::", var.codebuild_role_arn))
    error_message = "CodeBuild role ARN must be a valid IAM role ARN"
  }
}

variable "source_repo_owner" {
  description = "Owner (user/organization) of the GitHub repository"
  type = string
}

variable "source_repo_name" {
  description = "Name of the GitHub repository"
  type = string
}

variable "buildspec_path" {
  description = "Path to the buildspec file in the repository"
  type = string
}

variable "BRANCH_NAME" {
  description = "Git branch name for the sandbox environment"
  type = string
}

variable "region" {
  description = "AWS region where resources will be created"
  type = string
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-\\d{1}$", var.region))
    error_message = "Region must be a valid AWS region identifier"
  }
}

variable "logs_bucket_name" {
  description = "Name of the S3 bucket where CodeBuild logs will be stored"
  type = string
}