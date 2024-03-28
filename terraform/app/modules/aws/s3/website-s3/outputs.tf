output "bucket_regional_domain_name" {
  value       = aws_s3_bucket.this.bucket_regional_domain_name
  description = "S3 Bucket Regional Domain Name"
}

output "replication_bucket_regional_domain_name" {
  value       = aws_s3_bucket.replication_bucket.bucket_regional_domain_name
  description = "S3 Bucket Regional Domain Name"
}

output "arn" {
  value       = aws_s3_bucket.this.arn
  description = "S3 Bucket Regional Domain Name"
}

output "bucket_notifications_arn" {
  value       = aws_sns_topic.bucket_notifications.arn
  description = "S3 Bucket Bucket Notifications Name"
}
