module "s3_bucket" {
  source = "../../modules/aws/s3/website-s3"

  domain_name = var.domain_name

  s3_bucket_custom_name         = var.s3_bucket_custom_name
  s3_bucket_versioning          = var.s3_bucket_versioning
  s3_bucket_public_access_block = var.s3_bucket_public_access_block
  deploy_sample_content         = var.deploy_sample_content

  aws_cloudfront_distribution_arn = module.cloudfront.arn

  tags = var.tags
}

module "dns" {
  source = "../../modules/aws/dns"

  domain_name = var.domain_name

  ttl_validation = var.ttl_validation
  ttl_route53_record = var.ttl_route53_record
  alias_zone_id = var.alias_zone_id

  aws_cloudfront_distribution_this_domain_name = module.cloudfront.domain_name
}

module "cloudfront" {
  source = "../../modules/aws/cloudfront"

  domain_name = var.domain_name

  aws_s3_bucket_this_bucket_regional_domain_name = module.s3_bucket.bucket_regional_domain_name

  aws_acm_certificate_arn = module.dns.arn
  aws_acm_certificate_id  = module.dns.id

  cloudfront_default_root_object      = var.cloudfront_default_root_object
  cloudfront_minimum_protocol_version = var.cloudfront_minimum_protocol_version
  cloudfront_custom_error_responses   = var.cloudfront_custom_error_responses
  cloudfront_price_class              = var.cloudfront_price_class
  cloudfront_min_ttl                  = var.cloudfront_min_ttl
  cloudfront_default_ttl              = var.cloudfront_default_ttl
  cloudfront_max_ttl                  = var.cloudfront_max_ttl

}