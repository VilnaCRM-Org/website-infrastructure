resource "aws_s3_bucket" "codepipeline_bucket" {
  #checkov:skip=CKV2_AWS_62: The event notifications of this bucket is not needed
  #checkov:skip=CKV_AWS_18: The access logging of this bucket is not needed
  #checkov:skip=CKV_AWS_144: Replication of this bucket is not needed
  #checkov:skip=CKV_AWS_145: Bucket has encryption by default
  #checkov:skip=CKV_AWS_21: Versioning of this bucket is not needed
  bucket        = "${var.project_name}-codepipeline-artifacts-${var.environment}"
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket" "codebuild_logs_bucket" {
  #checkov:skip=CKV2_AWS_62: The event notifications of this bucket is not needed
  #checkov:skip=CKV_AWS_18: The access logging of this bucket is not needed
  #checkov:skip=CKV2_AWS_61: The lifecycle configuration of this bucket is not needed
  #checkov:skip=CKV_AWS_144: Replication of this bucket is not needed
  #checkov:skip=CKV_AWS_145: Bucket has encryption by default
  #checkov:skip=CKV_AWS_21: Versioning of this bucket is not needed
  bucket        = "${var.project_name}-codebuild-logs-${var.environment}"
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket" "access_logs_bucket" {
  #checkov:skip=CKV2_AWS_62: The event notifications of this bucket is not needed
  #checkov:skip=CKV_AWS_18: The access logging of this bucket is not needed
  #checkov:skip=CKV_AWS_144: Replication of this bucket is not needed
  #checkov:skip=CKV_AWS_145: Bucket has encryption by default
  #checkov:skip=CKV_AWS_21: Versioning of this bucket is not needed
  #checkov:skip=CKV2_AWS_61: The lifecycle configuration of this bucket is not needed
  bucket        = "${var.project_name}-access-logs-${var.environment}"
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_public_access_block" "codepipeline_bucket" {
  bucket                  = aws_s3_bucket.codepipeline_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "codebuild_logs_bucket" {
  bucket                  = aws_s3_bucket.codebuild_logs_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "access_logs_bucket" {
  bucket                  = aws_s3_bucket.access_logs_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "codepipeline_bucket_lifecycle_configuration" {
  depends_on = [aws_s3_bucket.codepipeline_bucket]

  bucket = aws_s3_bucket.codepipeline_bucket.id

  rule {
    id = "files-deletion"

    abort_incomplete_multipart_upload {
      days_after_initiation = var.s3_artifacts_bucket_files_deletion_days
    }

    expiration {
      days = var.s3_artifacts_bucket_files_deletion_days
    }

    status = "Enabled"
  }
}