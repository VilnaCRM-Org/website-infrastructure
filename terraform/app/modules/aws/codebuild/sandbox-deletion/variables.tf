variable "project_name" {
  description = "Name of the CodeBuild project for sandbox deletion"
  type        = string
  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9\\-_]{1,254}$", var.project_name))
    error_message = "Project name must be between 2 and 255 characters, start with a letter or number, and can contain hyphens and underscores"
  }
}

variable "codebuild_role_arn" {
  description = "ARN of the IAM role to be used by CodeBuild"
  type        = string
  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/[a-zA-Z0-9+=,.@\\-_/]+$", var.codebuild_role_arn))
    error_message = "CodeBuild role ARN must be a valid IAM role ARN in the format arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME"
  }
}

variable "source_repo_owner" {
  description = "Owner (user/organization) of the GitHub repository"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9](?:[a-zA-Z0-9]|-(?=[a-zA-Z0-9])){0,38}$", var.source_repo_owner))
    error_message = "GitHub owner must follow GitHub username requirements"
  }
}

variable "source_repo_name" {
  description = "Name of the GitHub repository"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]+$", var.source_repo_name))
    error_message = "Repository name must contain only alphanumeric characters, periods, hyphens, and underscores"
  }
}

variable "buildspec_path" {
  description = "Path to the buildspec file in the repository"
  type        = string
}

variable "BRANCH_NAME" {
  description = "Git branch name for the sandbox environment"
  type        = string
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-\\d{1}$", var.region))
    error_message = "Region must be a valid AWS region identifier"
  }
}

variable "logs_bucket_arn" {
  description = "ARN of the S3 bucket where CodeBuild logs will be stored"
  type        = string
  validation {
    condition     = can(regex("^arn:aws:s3:::[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.logs_bucket_arn))
    error_message = "S3 bucket ARN must be a valid ARN starting with 'arn:aws:s3:::' followed by a bucket name between 3 and 63 characters, containing only lowercase letters, numbers, dots, and hyphens, and starting/ending with a letter or number."
  }
}