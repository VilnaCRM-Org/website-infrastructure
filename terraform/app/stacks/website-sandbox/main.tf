module "sandobx_bucket" {
  source = "../../modules/aws/s3/public"

  project_name = "${var.SANDBOX_BUCKET_NAME}-${var.project_name}"

  s3_artifacts_bucket_files_deletion_days = var.s3_artifacts_bucket_files_deletion_days

  tags = var.tags
}
