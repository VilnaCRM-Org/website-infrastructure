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

variable "artifact_access_log_retention_days" {
  description = "Current and noncurrent expiry days for artifact access logs; a shorter bucket-wide expiry still applies"
  type        = number
  default     = 7

  validation {
    condition     = var.artifact_access_log_retention_days > 0 && floor(var.artifact_access_log_retention_days) == var.artifact_access_log_retention_days
    error_message = "Artifact access log retention must be a positive whole number of days."
  }
}

variable "access_log_source_bucket_names" {
  description = "Exact source bucket names allowed to deliver access logs to their own prefixes"
  type        = set(string)
  default     = []
}

variable "tags" {
  description = "Tags to be attached to the CodePipeline"
  type        = map(any)
}
