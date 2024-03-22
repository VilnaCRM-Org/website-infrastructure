variable "project_name" {
  description = "Name of the project to be prefixed to create the s3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment for this project"
  type        = string
}

variable "region" {
  description = "Region for this project"
  type        = string
}

variable "domain_name" {
  type        = string
  description = "Domain name for website, used for all resources"
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

variable "deploy_sample_content" {
  type        = bool
  default     = false
  description = "Deploy sample content to show website working?"
}

variable "cloudfront_default_root_object" {
  type        = string
  description = "Default root object for cloudfront. Need to also provide custom error response if changing from default"
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

variable "cloudfront_custom_error_responses" {
  type = list(object({
    error_code            = number
    response_code         = number
    error_caching_min_ttl = number
    response_page_path    = string
  }))
  description = "See https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/GeneratingCustomErrorResponses.html"
}

variable "cloudfront_access_control_max_age_sec" {
  type        = number
  description = "Value of Policy Access Control Max Age Sec"
}

variable "ttl_validation" {
  type        = number
  description = "TTL of AWS Route53 Record Validation"
}

variable "ttl_route53_record" {
  type        = number
  description = "TTL of AWS Route53 Record of WWW Domain Name"
}

variable "alias_zone_id" {
  type        = string
  description = "Zone ID for the record alias"
}

variable "SLACK_WORKSPACE_ID" {
  description = "Slack Workspace ID for Notifications"
  type        = string
}

variable "ALERTS_SLACK_CHANNEL_ID" {
  description = "Slack Channel ID for Notifications"
  type        = string
}

variable "lambda_python_version" {
  description = "Python version for Lambda"
  type        = string
}

variable "lambda_reserved_concurrent_executions" {
  description = "Function-level concurrent execution Limit for Lambda"
  type        = number
}

variable "create_slack_notification" {
  description = "This responsible for creating Slack Notifications"
  type        = string
}

variable "tags" {
  description = "Tags to be associated with the S3 bucket"
  type        = map(any)
}

