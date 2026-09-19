output "DOMAIN_NAME" {
  description = "Website endpoint"
  value       = var.domain_name
}

output "WAF_WEB_ACL_ARN" {
  description = "Canonical shared CloudFront WAF ACL ARN (null when WAF is disabled)"
  value       = module.cloudfront.waf_web_acl_arn
}

output "PRODUCTION_DISTRIBUTION_ID" {
  description = "Distribution ID"
  value       = module.cloudfront.id
}

output "CONTINUOUS_DEPLOYMENT_ID" {
  description = "CD ID"
  value       = module.cloudfront.continuous_deployment_id
}
