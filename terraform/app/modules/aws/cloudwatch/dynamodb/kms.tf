resource "aws_kms_key" "cloudwatch_encryption_key" {
  description             = "This key is used to encrypt cloudwatch logs"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_kms_key_policy" "cloudwatch_encryption_key" {
  key_id = aws_kms_key.cloudwatch_encryption_key.key_id
  policy = data.aws_iam_policy_document.cloudwatch_kms_key_policy_doc.json

  depends_on = [aws_kms_key.cloudwatch_encryption_key]
}