variable "domain_name" {
  type        = string
  description = "Domain name for website, used for all resources"
}

variable "aws_cloudfront_distribution_this_domain_name" {
  type        = string
  description = "The Domain Name of the CloudFront Distribution"
}