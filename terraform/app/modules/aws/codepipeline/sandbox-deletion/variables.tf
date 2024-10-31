variable "project_name" {
  description = "The name of the project used for resource naming"
  type        = string
  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9\\-_]{1,254}$", var.project_name))
    error_message = "Project name must be between 2 and 255 characters, start with a letter or number, and can contain hyphens and underscores"
  }
}

variable "codepipeline_role_arn" {
  description = "ARN of the IAM role for CodePipeline execution"
  type        = string
  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/[a-zA-Z0-9+=,.@\\-_/]+$", var.codepipeline_role_arn))
    error_message = "CodePipeline role ARN must be a valid IAM role ARN in the format arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME"
  }
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for pipeline artifacts"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.s3_bucket_name)) && !can(regex("\\.\\.", var.s3_bucket_name))
    error_message = "S3 bucket name must be between 3 and 63 characters, start and end with a lowercase letter or number, contain only lowercase letters, numbers, dots, and hyphens, and cannot contain consecutive dots."
  }
}

variable "codestar_connection_arn" {
  description = "ARN of the CodeStar connection for GitHub access"
  type        = string
  validation {
    condition     = can(regex("^arn:aws:codestar-connections:[a-zA-Z0-9-]+:[0-9]{12}:connection/[a-zA-Z0-9-]+$", var.codestar_connection_arn))
    error_message = "CodeStar connection ARN must be in the format arn:aws:codestar-connections:REGION:ACCOUNT_ID:connection/CONNECTION_ID."
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
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9._-]{0,98}[a-zA-Z0-9]$", var.source_repo_name)) && !endswith(var.source_repo_name, ".git")
    error_message = "Source repository name must start and end with an alphanumeric character, be up to 100 characters long, contain only alphanumeric characters, dots, underscores, and hyphens, and must not end with '.git'."
  }
}

variable "source_repo_branch" {
  description = "Branch name to track in the GitHub repository"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9/_.-]*[a-zA-Z0-9]$", var.source_repo_branch)) && !can(regex("\\.\\.", var.source_repo_branch))
    error_message = "Branch name must contain only alphanumeric characters, underscores, dots, and hyphens."
  }
}

variable "codebuild_project_name" {
  description = "Name of the CodeBuild project for sandbox deletion"
  type        = string
  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9\\-_]{1,254}$", var.codebuild_project_name))
    error_message = "CodeBuild project name must be between 2 and 255 characters, start with a letter or number, and can contain hyphens and underscores."
  }
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}