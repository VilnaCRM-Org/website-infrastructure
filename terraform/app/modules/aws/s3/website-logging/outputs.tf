output "arn" {
  value       = aws_s3_bucket.logging_bucket.arn
  description = "ARN of the logging bucket"
  depends_on  = [aws_s3_bucket.logging_bucket]
}

output "id" {
  value       = aws_s3_bucket.logging_bucket.id
  description = "ID of the logging bucket"
  depends_on  = [aws_s3_bucket.logging_bucket]
}

output "bucket_domain_name" {
  value       = aws_s3_bucket.logging_bucket.bucket_domain_name
  description = "Bucket Domain of the logging bucket"
  depends_on  = [aws_s3_bucket.logging_bucket]
}