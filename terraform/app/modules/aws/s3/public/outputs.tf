output "arn" {
  value       = aws_s3_bucket.reports_bucket.arn
  description = "ARN of the public bucket"
}

output "id" {
  value       = aws_s3_bucket.reports_bucket.id
  description = "ID of the public bucket"
}