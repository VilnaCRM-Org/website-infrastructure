variable "domain_name" {
  type        = string
  description = "Domain name for website, used for all resources"
}

variable "aws_cloudfront_distribution_this_domain_name" {
  type        = string
  description = "The Domain Name of the CloudFront Distribution"
}

variable "ttl_validation" {
  type        = number
  description = "TTL of AWS Route53 Record Validation"
}

variable "ttl_route53_record" {
  type        = string
  description = "TTL of AWS Route53 Record of WWW Domain Name"
}

variable "alias_zone_id" {
  type        = string
  description = "Zone ID for the record alias"
}