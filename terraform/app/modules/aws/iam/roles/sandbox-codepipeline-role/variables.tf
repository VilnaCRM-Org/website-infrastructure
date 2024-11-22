variable "project_name" {
  description = "Name of the project used for resource naming and tagging"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.project_name))
    error_message = "Project name must start with a letter and can contain only letters, numbers, and hyphens."
  }
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-\\d{1}$", var.region))
    error_message = "Region must be a valid AWS region identifier"
  }
}

variable "environment" {
  description = "Deployment environment (e.g., test, prod)"
  type        = string
  validation {
    condition     = contains(["prod", "test"], var.environment)
    error_message = "Environment must be one of: prod, test."
  }
}

variable "source_repo_owner" {
  description = "Source repo owner of the GitHub repository"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.source_repo_owner)) && length(var.source_repo_owner) <= 39
    error_message = "source_repo_owner must be a valid GitHub username containing only alphanumeric characters and hyphens, and be at most 39 characters long."
  }
}

variable "source_repo_name" {
  description = "Source repo name of the repository"
  type        = string
  validation {
    condition     = can(regex("^[\\w.-]+(/[\\w.-]+)*$", var.source_repo_name))
    error_message = "source_repo_name must be a valid repository name containing only alphanumeric characters, dots, underscores, or hyphens"
  }
}

variable "codepipeline_iam_role_name" {
  description = "Name of the IAM role to be used by the project"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9+=,.@_-]{1,64}$", var.codepipeline_iam_role_name))
    error_message = "codepipeline_iam_role_name must be 1-64 characters long and can include alphanumeric characters, +=,.@_-"
  }
}

variable "tags" {
  description = "Tags to be attached to the IAM Role"
  type        = map(string)
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 Bucket"
  type        = string
  validation {
    condition     = can(regex("^arn:aws:s3:::([a-zA-Z0-9-_.]+)$", var.s3_bucket_arn))
    error_message = "The S3 Bucket ARN must be in a valid format, e.g., arn:aws:s3:::my-bucket-name."
  }
}

variable "codestar_connection_arn" {
  description = "The ARN of the CodeStar connection"
  type        = string
  validation {
    condition     = can(regex("^arn:aws:codeconnections:[a-z0-9-]+:\\d{12}:connection/[a-zA-Z0-9-]+$", var.codestar_connection_arn))
    error_message = "codestar_connection_arn must be a valid AWS CodeStar connection ARN in the format arn:aws:codestar-connections:<region>:<account-id>:connection/<connection-id>."
  }
}

variable "policy_arns" {
  type        = map(map(string))
  description = "Map of IAM policies to attach to the role. Format: { policy_name = { arn = 'policy_arn' } }"
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

variable "BRANCH_NAME" {
  description = "Name of the branch"
  type        = string
  validation {
    condition     = can(regex("^[\\w.-]+(/[\\w.-]+)*$", var.BRANCH_NAME))
    error_message = "Branch name must be a valid Git branch name (e.g., 'main', 'feature/new-sandbox', 'bugfix/issue-123')"
  }
}