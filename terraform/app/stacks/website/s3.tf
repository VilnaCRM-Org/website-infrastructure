module "s3_bucket" {
  source = "../../modules/aws/s3/website"

  domain_name = var.domain_name

  project_name = var.project_name

  region      = var.region
  environment = var.environment

  lambda_configuration                = var.lambda_configuration
  cloudwatch_log_group_retention_days = var.cloudwatch_log_group_retention_days

  s3_bucket_custom_name         = var.s3_bucket_custom_name
  s3_bucket_versioning          = var.s3_bucket_versioning
  s3_bucket_public_access_block = var.s3_bucket_public_access_block
  deploy_sample_content         = var.deploy_sample_content

  s3_logging_bucket_id             = module.logging_s3_bucket.id
  replication_s3_logging_bucket_id = module.logging_s3_bucket.replication_id

  aws_cloudfront_distribution_arn = module.cloudfront.arn

  tags = var.tags
}

module "staging_s3_bucket" {
  source = "../../modules/aws/s3/website"

  domain_name = "staging.${var.domain_name}"

  project_name = "${var.project_name}-staging"

  region      = var.region
  environment = var.environment

  lambda_configuration                = var.lambda_configuration
  cloudwatch_log_group_retention_days = var.cloudwatch_log_group_retention_days

  s3_bucket_custom_name         = "staging-${var.s3_bucket_custom_name}"
  s3_bucket_versioning          = var.s3_bucket_versioning
  s3_bucket_public_access_block = var.s3_bucket_public_access_block
  deploy_sample_content         = var.deploy_sample_content

  s3_logging_bucket_id             = module.logging_s3_bucket.id
  replication_s3_logging_bucket_id = module.logging_s3_bucket.replication_id

  aws_cloudfront_distribution_arn = module.cloudfront.staging_arn
  
  tags = var.tags
}