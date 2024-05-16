resource "aws_s3_bucket" "replication_logging_bucket" {
  provider = aws.eu-west-1
  bucket   = "${var.project_name}-replication-logging-bucket"
  #checkov:skip=CKV_AWS_18:The access logging of logging bucket is not needed 
  #checkov:skip=CKV2_AWS_62: The event notifications of logging bucket is not needed 
  #checkov:skip=CKV_AWS_144: Replication of logging bucket is not needed 
  tags = var.tags

  force_destroy = local.allow_force_destroy
}

resource "aws_s3_bucket_policy" "replication_logging_bucket_policy" {
  provider = aws.eu-west-1
  bucket   = aws_s3_bucket.replication_logging_bucket.id
  policy   = data.aws_iam_policy_document.replication_bucket_policy_doc.json
}

resource "aws_s3_bucket_public_access_block" "replication_logging_bucket_pab" {
  provider                = aws.eu-west-1
  bucket                  = aws_s3_bucket.replication_logging_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "replication_logging_bucket_versioning" {
  provider = aws.eu-west-1
  bucket   = aws_s3_bucket.replication_logging_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "replication_logging_bucket_ownership" {
  provider = aws.eu-west-1
  #checkov:skip=CKV2_AWS_65: Needed for CloudFront
  bucket = aws_s3_bucket.replication_logging_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "replication_logging_bucket_acl" {
  provider   = aws.eu-west-1
  depends_on = [aws_s3_bucket_ownership_controls.replication_logging_bucket_ownership]

  bucket = aws_s3_bucket.replication_logging_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "replication_logging_bucket_lifecycle_configuration" {
  provider   = aws.eu-west-1
  depends_on = [aws_s3_bucket_versioning.replication_logging_bucket_versioning]

  bucket = aws_s3_bucket.replication_logging_bucket.id

  rule {
    id = "files-deletion"

    abort_incomplete_multipart_upload {
      days_after_initiation = var.s3_logs_lifecycle_configuration.deletion_days
    }

    expiration {
      days = var.s3_logs_lifecycle_configuration.deletion_days
    }

    transition {
      days          = var.s3_logs_lifecycle_configuration.standard_ia_transition_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.s3_logs_lifecycle_configuration.glacier_transition_days
      storage_class = "GLACIER"
    }

    transition {
      days          = var.s3_logs_lifecycle_configuration.deep_archive_transition_days
      storage_class = "DEEP_ARCHIVE"
    }

    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "replication_logging_bucket_server_side_encryption_configuration" {
  provider = aws.eu-west-1
  bucket   = aws_s3_bucket.replication_logging_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.replication_s3_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}