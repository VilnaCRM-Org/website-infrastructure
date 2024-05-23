project_name = "website-test"
environment  = "test"
tags = {
  Project     = "website"
  Environment = "test"
}
domain_name                   = "vilnacrmtest.com"
s3_bucket_custom_name         = "vilnacrmtest.com"
s3_bucket_versioning          = true
s3_bucket_public_access_block = true
deploy_sample_content         = true

cloudfront_configuration = {
  price_class                = "PriceClass_100"
  min_ttl                    = 0
  default_ttl                = 86400
  max_ttl                    = 31536000
  access_control_max_age_sec = 31536000
}

ttl_validation     = 60
ttl_route53_record = "300"