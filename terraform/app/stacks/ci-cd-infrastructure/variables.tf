variable "project_name" {
  description = "Unique name for the project"
  type        = string
}

variable "website_infra_project_name" {
  description = "Unique name for this Website Codepipeline"
  type        = string
}

variable "ci_cd_infra_project_name" {
  description = "Unique name for this CI/CD Codepipeline"
  type        = string
}

variable "ci_cd_website_project_name" {
  description = "Unique name for this Website Deploy Codepipeline"
  type        = string
}

variable "environment" {
  description = "Environment for this project"
  type        = string
}

variable "region" {
  description = "Region for this project"
  type        = string
}

variable "website_infra_buildspecs" {
  description = "Buildspecs of Website infrastructure"
  type        = string
}

variable "ci_cd_infra_buildspecs" {
  description = "Buildspecs of CI/CD infrastructure"
  type        = string
}

variable "ci_cd_website_buildspecs" {
  description = "Buildspecs of Website Deploy"
  type        = string
}

variable "source_repo_owner" {
  description = "Source repo owner of the GitHub repository"
  type        = string
}

variable "source_repo_name" {
  description = "Infrastructure Source repo name of the repository"
  type        = string
}

variable "website_content_repo_name" {
  description = "Infrastructure Source repo name of the Website repository"
  type        = string
}

variable "source_repo_branch" {
  description = "Default branch in the Source repo for which CodePipeline needs to be configured"
  type        = string
}

variable "github_connection_name" {
  description = "Name of the CodeStar connection"
  type        = string
}

variable "codepipeline_iam_role_name" {
  description = "Name of the IAM role to be used by the Codepipeline"
  type        = string
  default     = "codepipeline-role"
}

variable "website_url" {
  description = "URL of website for healthcheck"
  type        = string
}

variable "ci_cd_infra_stage_input" {
  description = "List of Map containing information about the stages of the CI/CD Infrastructure CodePipeline"
  type        = list(map(string))
}

variable "website_infra_stage_input" {
  description = "List of Map containing information about the stages of the Website Infrastructure CodePipeline"
  type        = list(map(string))
}

variable "ci_cd_website_stage_input" {
  description = "List of Map containing information about the stages of the Website Infrastructure CodePipeline"
  type        = list(map(string))
}

variable "ubuntu_builder_image" {
  description = "Docker Image to be used by CodeBuild"
  type        = string
}

variable "amazonlinux2_builder_image" {
  description = "Docker Image to be used by CodeBuild"
  type        = string
}

variable "default_builder_compute_type" {
  description = "Relative path to the Apply and Destroy build spec file"
  type        = string
}

variable "default_builder_type" {
  description = "Type of codebuild run environment"
  type        = string
}

variable "default_builder_image_pull_credentials_type" {
  description = "Image pull credentials type used by codebuild project"
  type        = string
}

variable "default_build_project_source" {
  description = "Source for build project"
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

variable "nodejs_version" {
  description = "Node.js Version to be used in codebuild stages"
  type        = string
}

variable "bucket_name" {
  description = "S3 Bucket Name for content"
  type        = string
}

variable "script_dir" {
  description = "Directory for Scripts of CodeBuild"
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

variable "ALERTS_SLACK_CHANNEL_ID" {
  description = "Slack Channel ID for Notifications"
  type        = string
}

variable "REPORT_SLACK_CHANNEL_ID" {
  description = "Slack Channel ID for Reports"
  type        = string
}

variable "lambda_python_version" {
  description = "Python version for Lambda"
  type        = string
}

variable "lambda_reserved_concurrent_executions" {
  description = "Function-level concurrent execution Limit for Lambda"
  type        = number
}

variable "create_slack_notification" {
  description = "This responsible for creating Slack Notifications"
  type        = string
}

variable "tags" {
  description = "Tags to be associated with the CI/CD Infrastructure"
  type        = map(any)
}