resource "aws_kms_key" "codepipeline_sns_encryption_key" {
  description             = "This key is used to encrypt codepipeline objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_kms_key_policy" "codepipeline_sns_encryption_key" {
  key_id = aws_kms_key.codepipeline_sns_encryption_key.key_id
  policy = data.aws_iam_policy_document.codepipeline_sns_kms_key_policy_doc.json

  depends_on = [aws_kms_key.codepipeline_sns_encryption_key]
}