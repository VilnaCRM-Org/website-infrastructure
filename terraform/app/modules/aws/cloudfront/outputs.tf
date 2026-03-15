output "arn" {
  value       = aws_cloudfront_distribution.this.arn
  description = "The ARN of the CloudFront Distribution"
}

output "id" {
  value       = aws_cloudfront_distribution.this.id
  description = "The ID of the CloudFront Distribution"
}

output "staging_arn" {
  value       = var.enable_cloudfront_staging ? aws_cloudfront_distribution.staging_cloudfront_distribution[0].arn : null
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
  value       = var.enable_waf ? aws_wafv2_web_acl.waf_web_acl[0].name : null
  description = "Name of the WAF2 Web ACL Of Distribution"
}

output "waf_log_group_name" {
  value       = var.enable_waf ? aws_cloudwatch_log_group.waf_web_acl_log_group[0].name : null
  description = "Name of the WAF2 Log Group"
}


output "continuous_deployment_id" {
  value       = var.enable_cloudfront_staging ? aws_cloudfront_continuous_deployment_policy.continuous_deployment_policy[0].id : null
  description = "The ID of the Continuous Deployment Policy"
}
