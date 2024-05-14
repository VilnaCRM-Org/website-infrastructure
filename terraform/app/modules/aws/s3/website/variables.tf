variable "aws_cloudfront_distribution_arn" {
  type        = string
  description = "CloudFront Distribution ARN"
}

variable "s3_logging_bucket_id" {
  type        = string
  description = "ID of the logging bucket"
}

variable "path_to_site_content" {
  type        = string
  description = "ID of the logging bucket"
  default     = "../../../../../.."
}

variable "path_to_lambdas" {
  type        = string
  description = "ID of the logging bucket"
  default     = "../../../../../../aws/lambda"
}

variable "domain_name" {
  type        = string
  description = "Domain name for website, used for all resources"
}

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

variable "s3_bucket_custom_name" {
  type        = string
  description = "Any non-empty string here will replace default name of bucket `var.domain_name`"
}

variable "s3_bucket_versioning" {
  type        = bool
  description = "Apply versioning to S3 bucket?"
}

variable "s3_bucket_public_access_block" {
  type        = bool
  description = "Apply public access block to S3 bucket?"
}

variable "deploy_sample_content" {
  type        = bool
  description = "Deploy sample content to show website working?"
}

variable "lambda_python_version" {
  description = "Python version for Lambda"
  type        = string
}

variable "lambda_reserved_concurrent_executions" {
  description = "Function-level concurrent execution Limit for Lambda"
  type        = number
}

variable "cloudwatch_log_group_retention_days" {
  description = "Retention time of Cloudwatch log group logs"
  type        = number
}

variable "tags" {
  description = "Tags to be associated with the S3 bucket"
  type        = map(any)
}
