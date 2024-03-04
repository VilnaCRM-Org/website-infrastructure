resource "aws_s3_bucket" "logging_bucket" {
  bucket_prefix = "${var.project_name}-logging-bucket"
  #checkov:skip=CKV2_AWS_61:The lifecycle configuration of logging bucket is not needed 
  #checkov:skip=CKV_AWS_145: The KMS encryptiono f logging bucket is not needed 
  #checkov:skip=CKV_AWS_144: Replication of logging bucket is not needed 
  tags = var.tags
}

resource "aws_s3_bucket_policy" "logging_bucket_policy" {
  bucket = aws_s3_bucket.logging_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy_doc.json
}