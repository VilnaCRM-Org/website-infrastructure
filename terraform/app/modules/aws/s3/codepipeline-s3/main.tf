#Artifact Bucket
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket_prefix = regex("[a-z0-9.-]+", lower(var.project_name))
  tags          = var.tags
  force_destroy = true
  #checkov:skip=CKV_AWS_144: No usage of cross-region
  #checkov:skip=CKV2_AWS_61: The lifecycle configuration is not needed 
  #checkov:skip=CKV2_AWS_62: The event notifications of logging bucket is not needed 
}

resource "aws_s3_bucket_public_access_block" "codepipeline_bucket_access" {
  bucket                  = aws_s3_bucket.codepipeline_bucket.id
  ignore_public_acls      = true
  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
}

resource "aws_s3_bucket_policy" "bucket_policy_codepipeline_bucket" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy_doc_codepipeline_bucket.json
}

resource "aws_s3_bucket_versioning" "codepipeline_bucket_versioning" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "codepipeline_bucket_encryption" {
  bucket = aws_s3_bucket.codepipeline_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_logging" "codepipeline_bucket_logging" {
  bucket        = aws_s3_bucket.codepipeline_bucket.id
  target_bucket = aws_s3_bucket.codepipeline_bucket.id
  target_prefix = "log/"
}
