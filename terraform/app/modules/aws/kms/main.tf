resource "aws_kms_key" "encryption_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_kms_key_policy" "encryption_key_policy" {
  key_id = aws_kms_key.encryption_key.key_id
  policy = data.aws_iam_policy_document.kms_key_policy_doc.json

  depends_on = [aws_kms_key.encryption_key]
}