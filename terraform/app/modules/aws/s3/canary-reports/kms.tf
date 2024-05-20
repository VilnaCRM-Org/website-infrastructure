resource "aws_kms_key" "canaries_reports_bucket_encryption_key" {
  #checkov:skip=CKV2_AWS_64:KMS Key Policy is not needed here
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}
