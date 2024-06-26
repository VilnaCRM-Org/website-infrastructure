variable "project_name" {
  description = "Name for the project"
  type        = string
}

variable "github_connection_name" {
  description = "Name of the CodeStar connection"
  type        = string
}

variable "s3_artifacts_bucket_files_deletion_days" {
  description = "Expiring time of files in buckets for lifecycle configuration rule"
  type        = number
}

variable "SANDBOX_BUCKET_NAME" {
  description = "Name for SandBox bucket"
  type        = string
}
