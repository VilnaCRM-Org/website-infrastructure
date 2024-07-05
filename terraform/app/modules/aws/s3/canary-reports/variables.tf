variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "s3_artifacts_bucket_files_deletion_days" {
  description = "Expiring time of files in buckets for lifecycle configuration rule"
  type        = number
}

variable "tags" {
  description = "Tags to be attached to the CodePipeline"
  type        = map(any)
}