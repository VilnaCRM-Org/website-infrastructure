variable "aws_region" {
  description = "The AWS region where resources will be deployed"
  type        = string
  default     = "us-east-1" # You can set a default value or remove this line if you always want to pass this variable explicitly
}

variable "site_domain" {
  type        = string
  description = "The domain name to use for the static site"
}

variable "s3_bucket_name" {
  type        = string
  description = "The s3 bucket name to use for the static site"
}

variable "environment" {
  type        = string
  description = "Environment of the static site"
}