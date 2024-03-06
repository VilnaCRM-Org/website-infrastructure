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