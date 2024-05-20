output "arn" {
  value       = aws_s3_bucket.canaries_reports_bucket.arn
  description = "ARN of Canaries Bucket"
  depends_on  = [aws_s3_bucket.canaries_reports_bucket]
}


output "id" {
  value       = aws_s3_bucket.canaries_reports_bucket.id
  description = "ARN of Canaries Bucket"
  depends_on  = [aws_s3_bucket.canaries_reports_bucket]
}
