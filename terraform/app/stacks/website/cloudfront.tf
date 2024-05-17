module "cloudfront" {
  source = "../../modules/aws/cloudfront"

  domain_name  = var.domain_name
  project_name = var.project_name

  aws_s3_bucket_this_bucket_regional_domain_name        = module.s3_bucket.bucket_regional_domain_name
  aws_s3_bucket_replication_bucket_regional_domain_name = module.s3_bucket.replication_bucket_regional_domain_name

  aws_acm_certificate_arn = module.dns.arn
  aws_acm_certificate_id  = module.dns.id

  logging_bucket_domain_name = module.logging_s3_bucket.bucket_domain_name

  cloudfront_default_root_object        = var.cloudfront_default_root_object
  cloudfront_minimum_protocol_version   = var.cloudfront_minimum_protocol_version
  cloudfront_custom_error_responses     = var.cloudfront_custom_error_responses
  cloudfront_price_class                = var.cloudfront_price_class
  cloudfront_min_ttl                    = var.cloudfront_min_ttl
  cloudfront_default_ttl                = var.cloudfront_default_ttl
  cloudfront_max_ttl                    = var.cloudfront_max_ttl
  cloudfront_access_control_max_age_sec = var.cloudfront_access_control_max_age_sec

  tags = var.tags
}
