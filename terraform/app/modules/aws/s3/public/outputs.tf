output "arn" {
  value       = aws_s3_bucket.reports_bucket.arn
  description = "ARN of the logging bucket"
}

output "id" {
  value       = aws_s3_bucket.reports_bucket.id
  description = "ID of the logging bucket"
}

output "name" {
  value       = aws_s3_bucket.reports_bucket.id
  description = "ID of the logging bucket"
}