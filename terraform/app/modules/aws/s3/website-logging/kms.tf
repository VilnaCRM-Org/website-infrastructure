resource "aws_kms_key" "s3_kms_key" {
  #checkov:skip=CKV2_AWS_64:KMS Key Policy is not needed here
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_key" "replication_s3_kms_key" {
  #checkov:skip=CKV2_AWS_64:KMS Key Policy is not needed here
  provider                = aws.eu-west-1
  description             = "This key is used to encrypt bucket objects of replication logs bucket"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}