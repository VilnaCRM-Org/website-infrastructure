variable "project_name" {
  description = "Unique name for the project"
  type        = string
}

variable "website_infra_project_name" {
  description = "Unique name for this Website CodePipeline"
  type        = string
}

variable "ci_cd_infra_project_name" {
  description = "Unique name for this CI/CD CodePipeline"
  type        = string
}

variable "sandbox_project_name" {
  description = "Unique name for this Sandbox CodePipeline"
  type        = string
}

variable "ci_cd_website_project_name" {
  description = "Unique name for this Website Deploy CodePipeline"
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

variable "cloudfront_configuration" {
  description = "CloudFront Configuration"
  type        = map(string)
}

variable "continuous_deployment_policy_weight" {
  description = "Continuous Deployment Policy Configuration Weight"
  type        = number
}

variable "continuous_deployment_policy_header" {
  description = "Continuous Deployment Policy Configuration Header"
  type        = string
}

variable "website_buildspecs" {
  description = "Buildspecs for Website"
  type        = string
}

variable "ci_cd_infra_buildspecs" {
  description = "Buildspecs for CI/CD infrastructure"
  type        = string
}

variable "ci_cd_website_buildspecs" {
  description = "Buildspecs for Website Deployment"
  type        = string
}

variable "sandbox_buildspecs" {
  description = "Buildspecs for Sandbox Deployment"
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

variable "website_repo_branch" {
  description = "Branch to be pulled from the website contents repository"
  type        = string
}

variable "github_connection_name" {
  description = "Name of the CodeStar connection"
  type        = string
}

variable "codepipeline_iam_role_name" {
  description = "Name of the IAM role to be used by the CodePipeline"
  type        = string
  default     = "codepipeline-role"
}

variable "website_url" {
  description = "URL of website for healthcheck"
  type        = string
}

variable "ci_cd_infra_stage_input" {
  description = "List of maps containing information about the stages of the CI/CD Infrastructure CodePipeline"
  type        = list(map(string))
}

variable "website_infra_stage_input" {
  description = "List of maps containing information about the stages of the Website Infrastructure CodePipeline"
  type        = list(map(string))
}

variable "sandbox_stage_input" {
  description = "List of maps containing information about the stages of the Sandbox CodePipeline"
  type        = list(map(string))
}

variable "sandbox_deletion_stage_input" {
  description = "List of maps containing information about the stages of the Sandbox CodePipeline"
  type        = list(map(string))
}

variable "ci_cd_website_stage_input" {
  description = "List of maps containing information about the stages of the Website Infrastructure CodePipeline"
  type        = list(map(string))
}

variable "codebuild_environment" {
  description = "Settings for the CodeBuild"
  type        = map(string)
}

variable "runtime_versions" {
  description = "Runtime Versions to be used in CodeBuild stages"
  type        = map(string)
}

variable "bucket_name" {
  description = "S3 Bucket Name for content"
  type        = string
}

variable "script_dir" {
  description = "Directory containing scripts for CodeBuild"
  type        = string
}

variable "s3_artifacts_bucket_files_deletion_days" {
  description = "Expiration time of files in buckets for lifecycle configuration rule"
  type        = number
}

variable "s3_logs_lifecycle_configuration" {
  description = "Expiring time of files in buckets for lifecycle configuration rule"
  type        = map(number)
}

variable "cloudwatch_log_group_retention_days" {
  description = "Retention time of CloudWatch Log Group logs"
  type        = number
}

variable "lambda_python_version" {
  description = "Python version for Lambda"
  type        = string
}

variable "lambda_reserved_concurrent_executions" {
  description = "Function-level concurrent execution Limit for Lambda"
  type        = number
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for logs"
  type        = string
}

variable "create_slack_notification" {
  description = "Responsible for creating Slack notifications"
  type        = string
}

variable "tags" {
  description = "Tags to be associated with the CI/CD Infrastructure"
  type        = map(any)
}

variable "SLACK_WORKSPACE_ID" {
  description = "Slack Workspace ID for Notifications"
  type        = string
}

variable "CODEPIPELINE_SLACK_CHANNEL_ID" {
  description = "Slack Channel ID for CodePipeline notifications"
  type        = string
}

variable "CI_CD_ALERTS_SLACK_CHANNEL_ID" {
  description = "Slack Channel ID for CI/CD alerts"
  type        = string
}

variable "WEBSITE_ALERTS_SLACK_CHANNEL_ID" {
  description = "Slack Channel ID for website alerts"
  type        = string
}

variable "REPORT_SLACK_CHANNEL_ID" {
  description = "Slack Channel ID for Reports"
  type        = string
}

variable "BRANCH_NAME" {
  description = "Name of the branch"
  type        = string
  default     = ""
}

variable "PR_NUMBER" {
  description = "Number of the pull request"
  type        = string
  default     = ""
}

variable "IS_PULL_REQUEST" {
  description = "Indicates if this is a pull request"
  type        = bool
  default     = false
}

variable "github_token_secret_name" {
  description = "Name of the GitHub token secret"
  type        = string
  default     = "github-token"
}