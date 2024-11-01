variable "project_name" {
  description = "Name of the project used for resource naming and tagging"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.project_name))
    error_message = "Project name must start with a letter and can contain only letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod", "test"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, test."
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

variable "account_id" {
  description = "AWS account ID"
  type        = string
  validation {
    condition     = can(regex("^\\d{12}$", var.account_id))
    error_message = "AWS account ID must be exactly 12 digits"
  }
}

variable "codestar_connection_arn" {
  description = "CodeStar connection ARN"
  type        = string
  validation {
    condition     = can(regex("^arn:aws:codeconnections:[\\w-]+:\\d{12}:connection/[\\w-]+$", var.codestar_connection_arn))
    error_message = "The ARN format is invalid. It must be a valid CodeStar connection ARN."
  }
}

variable "BRANCH_NAME" {
  description = "Name of the branch"
  type        = string
  validation {
    condition     = can(regex("^[\\w.-]+(/[\\w.-]+)*$", var.BRANCH_NAME))
    error_message = "Branch name must be a valid Git branch name (e.g., 'main', 'feature/new-sandbox', 'bugfix/issue-123')"
  }
}