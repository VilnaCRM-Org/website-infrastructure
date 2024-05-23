resource "aws_kms_key" "s3_kms_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_key" "replication_s3_kms_key" {
  provider                = aws.eu-west-1
  description             = "This key is used to encrypt bucket objects of replication logs bucket"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_key_policy" "s3_kms_key_policy" {
  key_id = aws_kms_key.s3_kms_key.key_id
  policy = data.aws_iam_policy_document.s3_kms_key_policy_doc.json

  depends_on = [aws_kms_key.s3_kms_key]
}

resource "aws_kms_key_policy" "replication_s3_kms_key_policy" {
  provider = aws.eu-west-1
  key_id   = aws_kms_key.replication_s3_kms_key.key_id
  policy   = data.aws_iam_policy_document.replication_s3_kms_key_policy_doc.json

  depends_on = [aws_kms_key.replication_s3_kms_key]
}