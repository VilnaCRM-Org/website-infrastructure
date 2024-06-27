module "sandbox_bucket" {
  source = "../../modules/aws/s3/public"

  project_name = "${var.project_name}-${var.SANDBOX_BUCKET_NAME}-bucket"

  s3_artifacts_bucket_files_deletion_days = var.s3_artifacts_bucket_files_deletion_days

  tags = var.tags
}
