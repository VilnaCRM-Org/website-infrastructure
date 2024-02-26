output "arn" {
  value       = aws_cloudfront_distribution.this.arn
  description = "The ARN of the CloudFront Distribution"
}
output "domain_name" {
  value       = aws_cloudfront_distribution.this.domain_name
  description = "The Domain Name of the CloudFront Distribution"
}