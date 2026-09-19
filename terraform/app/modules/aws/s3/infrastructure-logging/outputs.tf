output "id" {
  value       = aws_s3_bucket.logging_bucket.id
  description = "ID of Logging Bucket"
  # Access logging must wait until the destination allows log delivery.
  depends_on = [aws_s3_bucket_policy.logging_bucket_policy]
}

output "arn" {
  value       = aws_s3_bucket.logging_bucket.arn
  description = "ARN of Logging Bucket"
  depends_on  = [aws_s3_bucket.logging_bucket]
}
