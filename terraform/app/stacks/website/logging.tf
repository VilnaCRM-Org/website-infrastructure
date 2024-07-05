module "logging_s3_bucket" {
  source = "../../modules/aws/s3/website-logging"

  project_name = var.project_name
  environment  = var.environment

  aws_cloudfront_distribution_arn = module.cloudfront.arn
  aws_s3_bucket_this_arn          = module.s3_bucket.arn
  aws_replication_s3_bucket_arn   = module.s3_bucket.replication_arn

  s3_logs_lifecycle_configuration = var.s3_logs_lifecycle_configuration

  tags = var.tags
}