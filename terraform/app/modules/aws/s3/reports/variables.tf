variable "project_name" {
  description = "Name of the project to be prefixed to create the s3 bucket"
  type        = string
}

variable "s3_bucket_files_deletion_days" {
  description = "Expiring time of files in buckets for lifecycle configuration rule"
  type        = number
}


variable "tags" {
  description = "Tags to be associated with the S3 bucket"
  type        = map(any)
}
