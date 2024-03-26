output "arn" {
  value       = aws_s3_bucket.logging_bucket.arn
  description = "ARN of the logging bucket"
}

output "id" {
  value       = aws_s3_bucket.logging_bucket.id
  description = "ID of the logging bucket"
}

output "bucket_domain_name" {
  value       = aws_s3_bucket.logging_bucket.bucket_domain_name
  description = "ID of the logging bucket"
}