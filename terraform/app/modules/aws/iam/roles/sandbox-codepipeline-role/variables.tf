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
  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]$", var.source_repo_owner))
    error_message = "Repository owner must be a valid GitHub username/organization name."
  }
}

variable "source_repo_name" {
  description = "Source repo name of the repository"
  type        = string
  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9-]*[A-Za-z0-9]$", var.source_repo_name))
    error_message = "Repository name must be a valid GitHub repository name."
  }
}

variable "codepipeline_iam_role_name" {
  description = "Name of the IAM role to be used by the project"
  type        = string
}

variable "tags" {
  description = "Tags to be attached to the IAM Role"
  type        = map(any)
}

variable "kms_key_arn" {
  description = "ARN of KMS key for encryption"
  type        = string
  validation {
    condition     = can(regex("^arn:aws[a-zA-Z-]*:kms:", var.kms_key_arn))
    error_message = "The KMS key ARN must be a valid AWS KMS ARN."
  }
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 Bucket"
  type        = string
  validation {
    condition     = can(regex("^arn:aws[a-zA-Z-]*:s3:", var.s3_bucket_arn))
    error_message = "The S3 bucket ARN must be a valid AWS S3 ARN."
  }
}

variable "codestar_connection_arn" {
  description = "The ARN of the CodeStar connection"
  type        = string
  validation {
    condition     = can(regex("^arn:aws[a-zA-Z-]*:codestar-connections:", var.codestar_connection_arn))
    error_message = "The CodeStar connection ARN must be a valid AWS CodeStar connections ARN."
  }
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