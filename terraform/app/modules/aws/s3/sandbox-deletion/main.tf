resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket        = "${var.project_name}-codepipeline-artifacts-${var.environment}"
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket" "codebuild_logs_bucket" {
  bucket        = "${var.project_name}-codebuild-logs-${var.environment}"
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket" "access_logs_bucket" {
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

resource "aws_s3_bucket_versioning" "access_logs_bucket" {
  bucket = aws_s3_bucket.access_logs_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "access_logs_bucket" {
  bucket = aws_s3_bucket.access_logs_bucket.id

  rule {
    id     = "log-expiration"
    status = "Enabled"

    expiration {
      days = 365
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}