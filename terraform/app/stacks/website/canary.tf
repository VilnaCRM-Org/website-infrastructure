module "canary_reports_bucket" {
  source = "../../modules/aws/s3/canary-reports"

  project_name = var.project_name

  s3_artifacts_bucket_files_deletion_days = var.s3_artifacts_bucket_files_deletion_days

  tags = var.tags
}

module "canary_iam_role" {
  source = "../../modules/aws/iam/roles/canary"

  project_name = var.project_name

  canaries_reports_bucket_arn = module.canary_reports_bucket.arn

  tags = var.tags
}

module "canary" {
  source = "../../modules/aws/cloudwatch/canary"

  project_name = var.project_name

  canaries_reports_bucket_id = module.canary_reports_bucket.id
  canaries_iam_role_arn      = module.canary_iam_role.arn
  canary_configuration       = var.canary_configuration

  domain_name = var.domain_name

  tags = var.tags
}