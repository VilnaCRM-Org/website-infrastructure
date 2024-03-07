resource "aws_kms_key" "bucket_sns_encryption_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_sns_topic" "bucket_notifications" {
  name = "${var.project_name}-bucket-notifications"

  kms_master_key_id = aws_kms_key.bucket_sns_encryption_key.id

  tags = var.tags

  depends_on = [aws_kms_key.bucket_sns_encryption_key]
}

resource "aws_sns_topic_policy" "bucket_notifications" {
  arn    = aws_sns_topic.bucket_notifications.arn
  policy = data.aws_iam_policy_document.sns_bucket_topic_doc.json

  depends_on = [aws_sns_topic.bucket_notifications]
}

resource "aws_kms_key_policy" "bucket_sns_encryption_key" {
  key_id = aws_kms_key.bucket_sns_encryption_key.key_id
  policy = data.aws_iam_policy_document.bucket_sns_kms_key_policy_doc.json

  depends_on = [aws_kms_key.bucket_sns_encryption_key]
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.this.id

  topic {
    topic_arn = aws_sns_topic.bucket_notifications.arn
    events    = ["s3:ObjectRemoved:*", "s3:ObjectAcl:Put"]
  }
  depends_on = [aws_sns_topic.bucket_notifications, aws_s3_bucket.this]
}

