#Artifact Bucket
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket_prefix = regex("[a-z0-9.-]+", lower(var.project_name))
  tags          = var.tags
  force_destroy = true
  #checkov:skip=CKV_AWS_144: No usage of cross-region
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

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_config" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  rule {
    id     = "Delete old incomplete multi-part uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_sns_topic" "bucket_notifications" {
  name = "${var.project_name}-bucket-notifications"

  kms_master_key_id = aws_kms_key.bucket_sns_encryption_key.id

  tags = var.tags
  
  depends_on = [aws_kms_key.bucket_sns_encryption_key]
}

resource "aws_sns_topic_policy" "bucket_notifications" {
  arn    = aws_sns_topic.bucket_notifications.arn
  policy = data.aws_iam_policy_document.bucket_topic_doc.json

  depends_on = [aws_sns_topic.bucket_notifications]
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  topic {
    topic_arn = aws_sns_topic.bucket_notifications.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
  depends_on = [aws_s3_bucket.codepipeline_bucket]
}

resource "aws_kms_key" "bucket_sns_encryption_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_kms_key_policy" "bucket_sns_encryption_key" {
  key_id = aws_kms_key.bucket_sns_encryption_key.key_id
  policy = data.aws_iam_policy_document.bucket_sns_kms_key_policy_doc.json

  depends_on = [aws_kms_key.bucket_sns_encryption_key]
}
