variable "aws_cloudfront_distribution_arn" {
  type        = string
  description = "CloudFront Distribution ARN"
}

variable "domain_name" {
  type        = string
  description = "Domain name for website, used for all resources"
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

variable "tags" {
  description = "Tags to be associated with the S3 bucket"
  type        = map(any)
}
