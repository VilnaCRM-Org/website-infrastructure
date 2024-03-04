variable "project_name" {
  description = "Name of the project to be prefixed to create the s3 bucket"
  type        = string
}

variable "aws_cloudfront_distribution_arn" {
  type        = string
  description = "CloudFront Distribution ARN"
}

variable "aws_s3_bucket_this_arn" {
  type        = string
  description = "S3 Logging Bucket ARN"
}


variable "tags" {
  description = "Tags to be associated with the S3 bucket"
  type        = map(any)
}
