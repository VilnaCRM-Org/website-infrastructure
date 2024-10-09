module "lhci_reports_bucket" {
  source = "../../modules/aws/s3/public"

  project_name = "${var.ci_cd_website_project_name}-lhci-reports-bucket"

  s3_artifacts_bucket_files_deletion_days = var.s3_artifacts_bucket_files_deletion_days

  tags = var.tags
}

module "test_reports_bucket" {
  source = "../../modules/aws/s3/public"

  project_name = "${var.ci_cd_website_project_name}-test-reports-bucket"

  s3_artifacts_bucket_files_deletion_days = var.s3_artifacts_bucket_files_deletion_days

  tags = var.tags
}