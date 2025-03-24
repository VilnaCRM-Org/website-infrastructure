variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "codepipeline_name" {
  description = "Unique name for this CodePipeline"
  type        = string
}

variable "source_repo_owner" {
  description = "Source repo owner of the GitHub repository"
  type        = string
}

variable "source_repo_name" {
  description = "Source repo name of the GitHub repository"
  type        = string
}

variable "source_repo_branch" {
  description = "Default branch in the Source repo for which CodePipeline needs to be configured"
  type        = string
}

variable "region" {
  description = "Region for this project"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name to be used for storing the artifacts"
  type        = string
}

variable "codepipeline_role_arn" {
  description = "ARN of the codepipeline IAM role"
  type        = string
}

variable "codestar_connection_arn" {
  description = "The ARN of the CodeStar connection"
  type        = string
}

variable "detect_changes" {
  description = "Method for detecting changes"
  type        = string
}

variable "tags" {
  description = "Tags to be attached to the CodePipeline"
  type        = map(string)
}

variable "stages" {
  description = "List containing information about the stages of the CodePipeline"
  type        = list(map(any))
}

variable "BRANCH_NAME" {
  type        = string
  description = "Name of the branch"
}

variable "PR_NUMBER" {
  type        = string
  description = "Number of the pull request"
}

variable "IS_PULL_REQUEST" {
  type        = bool
  description = "Indicates if this is a pull request"
}

variable "notification_rule_suffix" {
  type        = string
  description = "Suffix for the notification rule to ensure uniqueness"
}

variable "path_to_lambdas" {
  type        = string
  description = "ID of the logging bucket"
  default     = "../../../../../../aws/lambda"
}

variable "lambda_reserved_concurrent_executions" {
  description = "Function-level concurrent execution Limit for Lambda"
  type        = number
}

variable "lambda_python_version" {
  description = "Python version for Lambda"
  type        = string
}