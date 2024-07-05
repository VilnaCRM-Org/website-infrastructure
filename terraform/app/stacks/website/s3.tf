module "s3_bucket" {
  source = "../../modules/aws/s3/website"

  staging = false

  domain_name = var.domain_name

  project_name = var.project_name

  region      = var.region
  environment = var.environment

  lambda_configuration                = var.lambda_configuration
  cloudwatch_log_group_retention_days = var.cloudwatch_log_group_retention_days

  s3_bucket_custom_name = var.s3_bucket_custom_name


  s3_logging_bucket_id             = module.logging_s3_bucket.id
  replication_s3_logging_bucket_id = module.logging_s3_bucket.replication_id

  aws_cloudfront_distributions_arns = [module.cloudfront.arn, module.cloudfront.staging_arn]

  tags = var.tags
}

module "staging_s3_bucket" {
  source = "../../modules/aws/s3/website"

  staging = true

  domain_name = "staging.${var.domain_name}"

  project_name = "${var.project_name}-staging"

  region      = var.region
  environment = var.environment

  lambda_configuration                = var.lambda_configuration
  cloudwatch_log_group_retention_days = var.cloudwatch_log_group_retention_days

  s3_bucket_custom_name = "staging.${var.s3_bucket_custom_name}"

  s3_logging_bucket_id             = module.logging_s3_bucket.id
  replication_s3_logging_bucket_id = module.logging_s3_bucket.replication_id

  aws_cloudfront_distributions_arns = [module.cloudfront.arn, module.cloudfront.staging_arn]

  tags = var.tags
}