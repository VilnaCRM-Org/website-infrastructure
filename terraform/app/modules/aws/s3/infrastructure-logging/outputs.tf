output "id" {
  value       = aws_s3_bucket.logging_bucket.id
  description = "ID of Logging Bucket"
  depends_on  = [aws_s3_bucket.logging_bucket]
}

output "arn" {
  value       = aws_s3_bucket.logging_bucket.arn
  description = "ARN of Logging Bucket"
  depends_on  = [aws_s3_bucket.logging_bucket]
}

