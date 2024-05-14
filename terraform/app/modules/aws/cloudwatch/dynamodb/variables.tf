variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "region" {
  description = "Region for this project"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Dynamodb Table Name for Logs"
  type        = string
}

variable "cloudwatch_log_group_retention_days" {
  description = "Retention time of Cloudwatch log group logs"
  type        = number
}

variable "tags" {
  description = "Tags to be attached to the CodePipeline"
  type        = map(any)
}