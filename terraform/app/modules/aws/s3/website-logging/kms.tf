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