variable "project_name" {
  description = "Name of the project to be prefixed to create the s3 bucket"
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

variable "s3_artifacts_bucket_files_deletion_days" {
  description = "Expiring time of files in buckets for lifecycle configuration rule"
  type        = number
}


variable "tags" {
  description = "Tags to be associated with the S3 bucket"
  type        = map(any)
}

variable "logging_bucket_id" {
  description = "Destination bucket for artifact access logs; its delivery policy must be ready before use"
  type        = string
}

variable "codepipeline_role_arn" {
  description = "ARN of the codepipeline IAM role"
  type        = string
}
