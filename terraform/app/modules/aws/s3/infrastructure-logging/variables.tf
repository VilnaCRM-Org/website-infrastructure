variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "region" {
  description = "Region for this project"
  type        = string
}

variable "s3_logs_lifecycle_configuration" {
  description = "Expiring time of files in buckets for lifecycle configuration rule"
  type        = map(number)
}

variable "tags" {
  description = "Tags to be attached to the CodePipeline"
  type        = map(any)
}