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