resource "aws_s3_bucket" "reports_bucket" {
  bucket = "${var.project_name}-reports-bucket"
  #checkov:skip=CKV_AWS_18:The access logging of reports bucket is not needed 
  #checkov:skip=CKV2_AWS_61:The lifecycle configuration of reports bucket is not needed 
  #checkov:skip=CKV2_AWS_62: The event notifications of reports bucket is not needed 
  #checkov:skip=CKV_AWS_145: The KMS encryption of reports bucket is not needed 
  #checkov:skip=CKV_AWS_144: Replication of reports bucket is not needed 
  #checkov:skip=CKV_AWS_20: Necessary for developer access
  #checkov:skip=CKV2_AWS_6: Bucket Alredy has PAB
  tags = var.tags

  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "reports_bucket_ownership_controls" {
  #checkov:skip=CKV2_AWS_65: Necessary for developer access /access control lists for S3 buckets are disabled
  bucket = aws_s3_bucket.reports_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_policy" "reports_bucket_policy" {
  bucket = aws_s3_bucket.reports_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy_doc.json
}

resource "aws_s3_bucket_public_access_block" "reports_bucket_pab" {
  #checkov:skip=CKV_AWS_56: Necessary for developer access /restrict_public_buckets enabled
  #checkov:skip=CKV_AWS_55: Necessary for developer access /ignore public ACLs enabled
  #checkov:skip=CKV_AWS_54: Necessary for developer access /block public policy enabled
  #checkov:skip=CKV_AWS_53: Necessary for developer access /public ACLS enabled
  bucket                  = aws_s3_bucket.reports_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "reports_bucket_versioning" {
  bucket = aws_s3_bucket.reports_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "reports_bucket_acl" {
  #ts:skip=AC_AWS_0210 
  depends_on = [
    aws_s3_bucket_ownership_controls.reports_bucket_ownership_controls,
    aws_s3_bucket_public_access_block.reports_bucket_pab,
  ]

  bucket = aws_s3_bucket.reports_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "reports_bucket_website_configuration" {
  bucket = aws_s3_bucket.reports_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "reports_bucket_lifecycle_configuration" {
  depends_on = [aws_s3_bucket_versioning.reports_bucket_versioning]

  bucket = aws_s3_bucket.reports_bucket.id

  rule {
    id = "files-deletion"

    abort_incomplete_multipart_upload {
      days_after_initiation = var.s3_bucket_files_deletion_days
    }

    expiration {
      days = var.s3_bucket_files_deletion_days
    }

    status = "Enabled"
  }
}
