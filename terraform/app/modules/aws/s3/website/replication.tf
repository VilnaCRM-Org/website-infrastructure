// Cross-Region replication

resource "aws_s3_bucket" "replication_bucket" {
  provider = aws.eu-west-1
  bucket   = "${var.s3_bucket_custom_name}-replication"
  #checkov:skip=CKV2_AWS_61: The lifecycle configuration is not needed 
  #checkov:skip=CKV_AWS_18:The cross-region access logging of logging bucket is not allowed(needs to have separate) 
  #checkov:skip=CKV2_AWS_62: The event notifications has to have separate endpoint 
  #checkov:skip=CKV_AWS_145: The KMS encryption is not needed
  force_destroy = local.allow_force_destroy
}

resource "aws_s3_bucket_public_access_block" "replication_bucket" {
  provider                = aws.eu-west-1
  bucket                  = aws_s3_bucket.replication_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "replication_versioning" {
  provider = aws.eu-west-1
  bucket   = aws_s3_bucket.replication_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "replication_bucket_logging" {
  provider = aws.eu-west-1
  bucket   = aws_s3_bucket.replication_bucket.id

  target_bucket = var.replication_s3_logging_bucket_id
  target_prefix = "s3-logs/"
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

