module "infrastructure_logging_bucket" {
  source = "../../modules/aws/s3/infrastructure-logging"

  project_name = var.ci_cd_infra_project_name
  region       = var.region

  s3_logs_lifecycle_configuration    = var.s3_logs_lifecycle_configuration
  artifact_access_log_retention_days = var.s3_artifacts_bucket_files_deletion_days

  # Derive names from inputs so the destination policy does not depend on source modules.
  access_log_source_bucket_names = [
    "${var.ci_cd_infra_project_name}-codepipeline-artifacts-bucket",
    "${var.ci_cd_website_project_name}-codepipeline-artifacts-bucket",
    "${var.website_infra_project_name}-codepipeline-artifacts-bucket",
    "${var.sandbox_project_name}-codepipeline-artifacts-bucket",
  ]

  tags = var.tags
}

module "dynamodb_logging" {

  source = "../../modules/aws/cloudwatch/dynamodb"

  project_name = var.ci_cd_infra_project_name
  region       = var.region

  cloudwatch_log_group_retention_days = var.cloudwatch_log_group_retention_days
  dynamodb_table_name                 = var.dynamodb_table_name

  logging_bucket_id = module.infrastructure_logging_bucket.id

  cloudwatch_alerts_sns_topic_arn = module.cloudwatch_alerts_sns.cloudwatch_alerts_sns_topic_arn
  enable_cloudwatch_alarms        = var.enable_cloudwatch_alarms

  tags = var.tags

  depends_on = [module.infrastructure_logging_bucket]
}
