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
  default     = ""
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
  description = "List of Names of the CodeBuild projects to be created"
  type        = list(string)
}

variable "builder_compute_type" {
  description = "Information about the compute resources the build project will use"
  type        = string
}

variable "builder_image" {
  description = "Docker image to use for the build project"
  type        = string
}

variable "builder_type" {
  description = "Type of build environment to use for related builds"
  type        = string
}

variable "builder_image_pull_credentials_type" {
  description = "Type of credentials AWS CodeBuild uses to pull images in your build."
  type        = string
}

variable "build_project_source" {
  description = "Information about the build output artifact location"
  type        = string
}

variable "ruby_version" {
  description = "Ruby Version to be used in codebuild stages"
  type        = string
}

variable "python_version" {
  description = "Python Version to be used in codebuild stages"
  type        = string
}

variable "script_dir" {
  description = "Directory for Scripts of CodeBuild"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of KMS key for encryption"
  type        = string
}

variable "SLACK_WORKSPACE_ID" {
  description = "Slack Workspace ID for Notifications"
  type        = string
}

variable "CODEPIPELINE_SLACK_CHANNEL_ID" {
  description = "Slack Channel ID for Notifications"
  type        = string
}

variable "WEBSITE_SLACK_CHANNEL_ID" {
  description = "Slack Channel ID for Notifications"
  type        = string
}

variable "secretsmanager_secret_name" {
  description = "Secret ID of Secret Manager"
  type        = string
}

variable "website_url" {
  description = "URL of website for healthcheck"
  type        = string
}