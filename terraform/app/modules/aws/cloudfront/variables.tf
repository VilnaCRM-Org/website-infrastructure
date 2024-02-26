variable "aws_s3_bucket_this_bucket_regional_domain_name" {
  type        = string
  description = "S3 Bucket Regional Domain Name"
}

variable "domain_name" {
  type        = string
  description = "Domain name for website, used for all resources"
}

variable "aws_acm_certificate_id" {
  type        = string
  description = "ID of ACM Certificate"
}

variable "aws_acm_certificate_arn" {
  type        = string
  description = "ARN of ACM Certificate"
}

variable "cloudfront_price_class" {
  type        = string
  description = "CloudFront distribution price class"
}
variable "cloudfront_min_ttl" {
  type        = number
  description = "The minimum TTL for the cloudfront cache"
}

variable "cloudfront_default_ttl" {
  type        = number
  description = "The default TTL for the cloudfront cache"
}

variable "cloudfront_max_ttl" {
  type        = number
  default     = 31536000
  description = "The maximum TTL for the cloudfront cache"
}

variable "cloudfront_minimum_protocol_version" {
  type        = string
  description = "The minimum version of the SSL protocol that you want CloudFront to use for HTTPS connections."
  default     = "TLSv1.2_2019"
}

variable "cloudfront_default_root_object" {
  type        = string
  description = "Default root object for cloudfront. Need to also provide custom error response if changing from default"
  default     = "index.html"
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
