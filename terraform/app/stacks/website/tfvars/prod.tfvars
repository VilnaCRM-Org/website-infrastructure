project_name = "website-prod"
environment  = "prod"
tags = {
  Project     = "website"
  Environment = "prod"
}
domain_name                           = "vilnacrm.com"
s3_bucket_custom_name                 = "vilnacrm.com"
s3_bucket_versioning                  = true
s3_bucket_public_access_block         = true
deploy_sample_content                 = true
cloudfront_price_class                = "PriceClass_100"
cloudfront_min_ttl                    = 0
cloudfront_default_ttl                = 86400
cloudfront_max_ttl                    = 31536000
cloudfront_access_control_max_age_sec = 31536000
ttl_validation                        = 60
ttl_route53_record                    = "300"
