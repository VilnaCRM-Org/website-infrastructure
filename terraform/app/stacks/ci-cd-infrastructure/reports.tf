module "lhci_reports_bucket" {
  source = "../../modules/aws/s3/reports"

  project_name = "${var.ci_cd_website_project_name}-lhci"

  s3_artifacts_bucket_files_deletion_days = var.s3_artifacts_bucket_files_deletion_days

  tags = var.tags
}

module "test_reports_bucket" {
  source = "../../modules/aws/s3/reports"

  project_name = "${var.ci_cd_website_project_name}-test"

  s3_artifacts_bucket_files_deletion_days = var.s3_artifacts_bucket_files_deletion_days

  tags = var.tags
}