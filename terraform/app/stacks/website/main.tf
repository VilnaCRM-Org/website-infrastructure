module "logging_s3_bucket" {
  source = "../../modules/aws/s3/website-logging"

  project_name = var.project_name
  environment  = var.environment

  aws_cloudfront_distribution_arn = module.cloudfront.arn
  aws_s3_bucket_this_arn          = module.s3_bucket.arn

  s3_bucket_files_deletion_days = var.s3_bucket_files_deletion_days

  tags = var.tags
}

module "s3_bucket" {
  source = "../../modules/aws/s3/website"

  domain_name = var.domain_name

  project_name = var.project_name

  region      = var.region
  environment = var.environment

  lambda_python_version                 = var.lambda_python_version
  lambda_reserved_concurrent_executions = var.lambda_reserved_concurrent_executions
  cloudwatch_log_group_retention_days   = var.cloudwatch_log_group_retention_days

  s3_bucket_custom_name         = var.s3_bucket_custom_name
  s3_bucket_versioning          = var.s3_bucket_versioning
  s3_bucket_public_access_block = var.s3_bucket_public_access_block
  deploy_sample_content         = var.deploy_sample_content

  s3_logging_bucket_id = module.logging_s3_bucket.id

  aws_cloudfront_distribution_arn = module.cloudfront.arn

  tags = var.tags
}

module "dns" {
  source = "../../modules/aws/dns"

  domain_name = var.domain_name

  ttl_validation     = var.ttl_validation
  ttl_route53_record = var.ttl_route53_record
  alias_zone_id      = var.alias_zone_id

  aws_cloudfront_distribution_this_domain_name = module.cloudfront.domain_name
}

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

module "chatbot" {
  count = var.create_slack_notification ? 1 : 0

  source = "../../modules/aws/chatbot"

  project_name   = "website-cloudfront-failover-alarm"
  channel_id     = var.ALERTS_SLACK_CHANNEL_ID
  workspace_id   = var.SLACK_WORKSPACE_ID
  sns_topic_arns = [module.cloudfront.cloudwatch_sns_topic_arn, module.s3_bucket.bucket_notifications_arn]

  tags = var.tags
}