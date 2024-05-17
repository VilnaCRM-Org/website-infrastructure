output "arn" {
  value       = aws_cloudfront_distribution.this.arn
  description = "The ARN of the CloudFront Distribution"
}
output "domain_name" {
  value       = aws_cloudfront_distribution.this.domain_name
  description = "The Domain Name of the CloudFront Distribution"
}

output "cloudwatch_sns_topic_arn" {
  value       = aws_sns_topic.cloudwatch_alarm_notifications.arn
  description = "The Domain Name of the CloudFront Distribution"
}

output "waf_web_acl_name" {
  value       = aws_wafv2_web_acl.waf_web_acl.name
  description = "Name of the WAF2 Web ACL Of Distribution"
}

output "waf_log_group_name" {
  value       = aws_cloudwatch_log_group.waf_web_acl_log_group.name
  description = "Name of the WAF2 Log Group"
}
