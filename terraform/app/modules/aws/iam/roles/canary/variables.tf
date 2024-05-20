variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "canaries_reports_bucket_arn" {
  description = "Canaries Reports Bucket ARN"
  type        = string
}

variable "tags" {
  description = "Tags to be attached to the CodePipeline"
  type        = map(any)
}