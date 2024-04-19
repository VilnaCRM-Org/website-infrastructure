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

variable "role_arn" {
  description = "Codepipeline IAM role arn. "
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket used to store the deployment artifacts"
  type        = string
}

variable "codepipeline_buildspecs" {
  description = "CodePipeline Buildspecs"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the codebuild project"
  type        = map(any)
}

variable "build_projects" {
  description = "List of Names of the CodeBuild projects to be created"
  type        = map(map(string))
}

variable "kms_key_arn" {
  description = "ARN of KMS key for encryption"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables"
  type        = map(string)
}