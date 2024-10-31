variable "project_name" {
  description = "The name of the project"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$", var.project_name)) && length(var.project_name) >= 3
    error_message = "Project name must only contain alphanumeric characters and hyphens, start and end with alphanumeric characters, and be at least 3 characters long."
  }
}
  
variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod", "test"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, test."
  }
}

variable "tags" {
  description = "A map of tags to assign to AWS resources"
  type        = map(string)
  validation {
    condition     = contains(keys(var.tags), "Owner") && contains(keys(var.tags), "CostCenter")
    error_message = "Tags must contain 'Owner' and 'CostCenter' keys."
  }
}