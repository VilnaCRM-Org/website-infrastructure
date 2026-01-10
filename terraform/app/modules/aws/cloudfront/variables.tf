variable "aws_s3_bucket_this_bucket_regional_domain_name" {
  type        = string
  description = "S3 Bucket Regional Domain Name"
}

variable "aws_s3_bucket_replication_bucket_regional_domain_name" {
  type        = string
  description = "S3 Replication Bucket Regional Domain Name"
}

variable "domain_name" {
  type        = string
  description = "Domain name for website, used for all resources"
}

variable "logging_bucket_domain_name" {
  type        = string
  description = "Domain name for logging bucket"
}

variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "tags" {
  description = "Tags to be associated with the CloudFront"
  type        = map(any)
}

variable "aws_acm_certificate_id" {
  type        = string
  description = "ID of ACM Certificate"
}

variable "aws_acm_certificate_arn" {
  type        = string
  description = "ARN of ACM Certificate"
  validation {
    condition     = can(regex("^arn:aws[a-z-]*:acm:[a-z0-9-]+:[0-9]{12}:certificate/[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$", trimspace(var.aws_acm_certificate_arn)))
    error_message = "aws_acm_certificate_arn must be a valid ACM certificate ARN (arn:aws:acm:<region>:<account-id>:certificate/<id>)."
  }
}

variable "enable_cloudfront_staging" {
  description = "This responsible for enabling Staging for Cloudfront"
  type        = bool
}

variable "cloudfront_configuration" {
  type        = map(any)
  description = "CloudFront Configuration"
}

variable "cloudfront_routing_function_url" {
  type        = string
  description = "CloudFront Routing Function URL"
  default     = "https://raw.githubusercontent.com/VilnaCRM-Org/website/main/scripts/cloudfront_routing.js"
}

variable "cloudfront_custom_error_responses" {
  type = list(object({
    error_code            = number
    response_code         = number
    error_caching_min_ttl = number
    response_page_path    = string
  }))
  description = "See https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/GeneratingCustomErrorResponses.html"
}
