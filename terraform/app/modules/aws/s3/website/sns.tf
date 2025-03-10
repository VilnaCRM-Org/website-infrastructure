resource "aws_sns_topic" "bucket_notifications" {
  #checkov:skip=CKV_AWS_26: KMS encryption is not needed
  name = "${var.project_name}-bucket-notifications"

  tags = var.tags
}

resource "aws_sns_topic_policy" "bucket_notifications" {
  arn    = aws_sns_topic.bucket_notifications.arn
  policy = data.aws_iam_policy_document.sns_bucket_topic_doc.json

  depends_on = [aws_sns_topic.bucket_notifications]
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.this.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.func.arn
    events              = ["s3:ObjectRemoved:*", "s3:ObjectAcl:Put"]
  }
  depends_on = [aws_sns_topic.bucket_notifications, aws_s3_bucket.this, aws_lambda_permission.allow_bucket]
}
