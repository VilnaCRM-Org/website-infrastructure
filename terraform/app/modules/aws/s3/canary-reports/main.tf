resource "aws_s3_bucket" "canaries_reports_bucket" {
  #checkov:skip=CKV_AWS_18:The access logging of logging bucket is not needed 
  #checkov:skip=CKV2_AWS_62: The event notifications of logging bucket is not needed 
  #checkov:skip=CKV_AWS_144: Replication of logging bucket is not needed
  #checkov:skip=CKV_AWS_145: Bucket has encryption by default
  bucket        = "${var.project_name}-canaries-reports-bucket"
  force_destroy = true

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "canaries_reports_bucket_block_public_access" {
  bucket                  = aws_s3_bucket.canaries_reports_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "canaries_reports_bucket_policy" {
  bucket = aws_s3_bucket.canaries_reports_bucket.id
  policy = data.aws_iam_policy_document.canaries_reports_bucket_policy_doc.json
}

resource "aws_s3_bucket_server_side_encryption_configuration" "canaries_reports_bucket_encryption_configuration" {
  bucket = aws_s3_bucket.canaries_reports_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "canaries_reports_bucket_versioning" {
  bucket = aws_s3_bucket.canaries_reports_bucket.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "canaries_reports_bucket_lifecycle_configuration" {
  depends_on = [aws_s3_bucket_versioning.canaries_reports_bucket_versioning]

  bucket = aws_s3_bucket.canaries_reports_bucket.id

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
