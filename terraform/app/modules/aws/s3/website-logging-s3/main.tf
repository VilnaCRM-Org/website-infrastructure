resource "aws_s3_bucket" "logging_bucket" {
  bucket = "${var.project_name}-logging-bucket"
  #checkov:skip=CKV_AWS_18:The access logging of logging bucket is not needed 
  #checkov:skip=CKV2_AWS_61:The lifecycle configuration of logging bucket is not needed 
  #checkov:skip=CKV2_AWS_62: The event notifications of logging bucket is not needed 
  #checkov:skip=CKV_AWS_145: The KMS encryption of logging bucket is not needed 
  #checkov:skip=CKV_AWS_144: Replication of logging bucket is not needed 
  tags = var.tags
}

resource "aws_s3_bucket_policy" "logging_bucket_policy" {
  bucket = aws_s3_bucket.logging_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy_doc.json
}

resource "aws_s3_bucket_public_access_block" "logging_bucket_pab" {
  bucket                  = aws_s3_bucket.logging_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "logging_bucket_versioning" {
  bucket = aws_s3_bucket.logging_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "logging_bucket_ownership" {
  #checkov:skip=CKV2_AWS_65: Needed for CloudFront
  bucket = aws_s3_bucket.logging_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "logging_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.logging_bucket_ownership]

  bucket = aws_s3_bucket.logging_bucket.id
  acl    = "private"
}