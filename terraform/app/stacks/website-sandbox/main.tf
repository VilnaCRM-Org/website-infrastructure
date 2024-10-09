module "sandbox_bucket" {
  source = "../../modules/aws/s3/public"

  project_name = "${var.project_name}-${var.sandbox_bucket_name}-bucket"

  s3_artifacts_bucket_files_deletion_days = var.s3_artifacts_bucket_files_deletion_days

  tags = var.tags
}
