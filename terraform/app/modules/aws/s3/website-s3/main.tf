resource "aws_s3_bucket" "this" {
  bucket = var.s3_bucket_custom_name
  #checkov:skip=CKV2_AWS_61:The lifecycle configuration is not needed 
  #checkov:skip=CKV_AWS_145: The KMS encryption is not needed 
  tags = var.tags
}

resource "aws_s3_bucket_logging" "bucket_logging" {
  bucket = aws_s3_bucket.this.id

  target_bucket = var.s3_logging_bucket_id
  target_prefix = "s3-logs/"
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_s3_bucket_versioning" "this" {
  count  = var.s3_bucket_versioning == true ? 1 : 0
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  count                   = var.s3_bucket_public_access_block == true ? 1 : 0
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "sample_index_html" {
  count        = var.deploy_sample_content == true ? 1 : 0
  bucket       = aws_s3_bucket.this.id
  key          = "index.html"
  source       = "${var.path_to_site_content}/site-content/index.html"
  content_type = "text/html"
  etag         = filemd5("${var.path_to_site_content}/site-content/index.html")
}

resource "aws_s3_object" "sample_logo_png" {
  count        = var.deploy_sample_content == true ? 1 : 0
  bucket       = aws_s3_bucket.this.id
  key          = "logo.png"
  source       = "${var.path_to_site_content}/site-content/logo.png"
  content_type = "text/html"
  etag         = filemd5("${var.path_to_site_content}/site-content/logo.png")
}

resource "aws_kms_key" "bucket_sns_encryption_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_sns_topic" "bucket_notifications" {
  name = "${var.project_name}-website-bucket-notifications"

  kms_master_key_id = aws_kms_key.bucket_sns_encryption_key.id

  tags = var.tags

  depends_on = [aws_kms_key.bucket_sns_encryption_key]
}

resource "aws_sns_topic_policy" "bucket_notifications" {
  arn    = aws_sns_topic.bucket_notifications.arn
  policy = data.aws_iam_policy_document.sns_bucket_topic_doc.json

  depends_on = [aws_sns_topic.bucket_notifications]
}

resource "aws_kms_key_policy" "bucket_sns_encryption_key" {
  key_id = aws_kms_key.bucket_sns_encryption_key.key_id
  policy = data.aws_iam_policy_document.bucket_sns_kms_key_policy_doc.json

  depends_on = [aws_kms_key.bucket_sns_encryption_key]
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.this.id

  topic {
    topic_arn     = aws_sns_topic.bucket_notifications.arn
    events        = ["s3:ObjectRemoved:*","s3:ObjectAcl:Put"]
  }
  depends_on = [aws_sns_topic.bucket_notifications, aws_s3_bucket.this]
}

// Cross-Region replication

resource "aws_s3_bucket" "replication_bucket" {
  bucket = "${var.s3_bucket_custom_name}-replication"
}

resource "aws_s3_bucket_logging" "replication_bucket_logging" {
  bucket = aws_s3_bucket.replication_bucket.id

  target_bucket = var.s3_logging_bucket_id
  target_prefix = "s3-replication-logs/"
}

resource "aws_s3_bucket_versioning" "replication_versioning" {
  bucket = aws_s3_bucket.replication_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "replication" {
  name               = "${var.s3_bucket_custom_name}-iam-role-replication"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "replication" {
  name   = "${var.s3_bucket_custom_name}-iam-role-policy-replication"
  policy = data.aws_iam_policy_document.replication.json
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.this, aws_s3_bucket_versioning.replication_versioning]

  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.this.id

  rule {
    id = "replication-id"

    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.replication_bucket.arn
      storage_class = "STANDARD"
    }
  }
}