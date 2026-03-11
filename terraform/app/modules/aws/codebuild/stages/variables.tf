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

variable "tags" {
  description = "Tags to be applied to the codebuild project"
  type        = map(any)
}

variable "build_projects" {
  description = "Map of CodeBuild project definitions to create. Projects may include optional build_batch_config settings."
  type = map(object({
    build_project_source                = string
    builder_compute_type                = string
    builder_image                       = string
    builder_image_pull_credentials_type = string
    builder_type                        = string
    buildspec                           = string
    env_variables                       = map(any)
    privileged_mode                     = bool
    build_batch_config = optional(object({
      combine_artifacts = optional(bool)
    }))
    git_clone_depth = optional(number)
  }))
}

variable "build_timeout" {
  description = "Timeout for the CodeBuild project"
  type        = number
  default     = 35
}
