module "infrastructure_logging_bucket" {
  source = "../../modules/aws/s3/infrastructure-logging"

  project_name = var.ci_cd_infra_project_name
  region       = var.region

  s3_logs_lifecycle_configuration = var.s3_logs_lifecycle_configuration

  tags = var.tags
}

module "dynamodb_logging" {
  source = "../../modules/aws/cloudwatch/dynamodb"

  project_name = var.ci_cd_infra_project_name
  region       = var.region

  cloudwatch_log_group_retention_days = var.cloudwatch_log_group_retention_days
  dynamodb_table_name                 = var.dynamodb_table_name

  logging_bucket_id = module.infrastructure_logging_bucket.id

  tags = var.tags

  depends_on = [module.infrastructure_logging_bucket]
}
