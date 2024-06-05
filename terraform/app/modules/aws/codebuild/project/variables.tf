variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "build_configuration" {
  description = "Configuration for CodeBuild Project"
  type        = map(any)
}

variable "env_variables" {
  description = "Configuration for CodeBuild Project"
  type        = map(any)
}

variable "region" {
  description = "Region for this project"
  type        = string
}

variable "environment" {
  description = "Environment for this project"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the codebuild project"
  type        = map(any)
}

variable "kms_key_arn" {
  description = "ARN of KMS key for encryption"
  type        = string
}

variable "role_arn" {
  description = "Codepipeline IAM role arn. "
  type        = string
}
