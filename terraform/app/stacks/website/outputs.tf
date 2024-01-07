output "domain_name" {
  description = "Website endpoint"
  value       = var.site_domain
}

output "cloudfront_domain_name" {
  value = module.static-website-s3-cloudfront-acm.cloudfront_domain_name
}

output "s3_bucket_arn" {
  value = module.static-website-s3-cloudfront-acm.s3_bucket_arn
}

output "s3_bucket_id" {
  value = module.static-website-s3-cloudfront-acm.s3_bucket_id
}

output "acm_certificate_id" {
  value = module.static-website-s3-cloudfront-acm.acm_certificate_id
}

output "website_url" {
  value = "www.${var.site_domain}"
}
