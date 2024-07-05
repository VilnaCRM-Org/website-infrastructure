output "DOMAIN_NAME" {
  description = "Website endpoint"
  value       = var.domain_name
}

output "PRODUCTION_DISTRIBUTION_ID" {
  description = "Distribution ID"
  value       = module.cloudfront.id
}

output "CONTINUOUS_DEPLOYMENT_ID" {
  description = "CD ID"
  value       = module.cloudfront.continuous_deployment_id
}