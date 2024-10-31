variable "project_name" {
  description = "The name of the project"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$", var.project_name)) && length(var.project_name) >= 3 && length(var.project_name) <= 63
    error_message = "Project name must be 3-63 characters long, contain only alphanumeric characters and hyphens, and must start and end with an alphanumeric character."
  }
}

variable "environment" {
  description = "The deployment environment for sandbox deletion resources"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod", "test"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, test."
  }
}

variable "tags" {
  description = "A map of tags to assign to AWS resources"
  type        = map(string)
}