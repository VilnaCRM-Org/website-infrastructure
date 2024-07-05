variable "project_name" {
  description = "Name of the project to be prefixed to create the s3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment for this project"
  type        = string
}

variable "aws_cloudfront_distribution_arn" {
  type        = string
  description = "CloudFront Distribution ARN"
}

variable "aws_s3_bucket_this_arn" {
  type        = string
  description = "S3 Bucket ARN of Website"
}

variable "aws_replication_s3_bucket_arn" {
  type        = string
  description = "Replication S3 Bucket ARN of Website"
}

variable "s3_logs_lifecycle_configuration" {
  description = "Expiring time of files in buckets for lifecycle configuration rule"
  type        = map(number)
}

variable "tags" {
  description = "Tags to be associated with the S3 bucket"
  type        = map(any)
}
