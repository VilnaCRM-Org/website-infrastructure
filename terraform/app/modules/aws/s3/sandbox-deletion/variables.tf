variable "project_name" {
  description = "The name of the project"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.project_name))
    error_message = "Project name must only contain alphanumeric characters and hyphens."
  }
}

variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod", "test"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "tags" {
  description = "A map of tags to assign to AWS resources"
  type        = map(string)
}