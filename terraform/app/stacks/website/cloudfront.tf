module "cloudfront" {
  source = "../../modules/aws/cloudfront"

  domain_name  = var.domain_name
  project_name = var.project_name

  aws_s3_bucket_this_bucket_regional_domain_name        = module.s3_bucket.bucket_regional_domain_name
  aws_s3_bucket_replication_bucket_regional_domain_name = module.s3_bucket.replication_bucket_regional_domain_name


  aws_acm_certificate_arn = module.dns.arn
  aws_acm_certificate_id  = module.dns.id

  logging_bucket_domain_name = var.enable_access_logging ? module.logging_s3_bucket.bucket_domain_name : null

  cloudfront_configuration          = var.cloudfront_configuration
  cloudfront_custom_error_responses = var.cloudfront_custom_error_responses
  cloudfront_routing_function_url   = "https://raw.githubusercontent.com/VilnaCRM-Org/website/main/scripts/cloudfront_routing.js"

  enable_access_logging        = var.enable_access_logging
  enable_cloudfront_staging    = var.enable_cloudfront_staging
  enable_cloudwatch_alarms     = var.enable_cloudwatch_alarms
  enable_waf                   = var.enable_waf
  enable_origin_latency_alarms = var.enable_origin_latency_alarms

  tags = var.tags
}
