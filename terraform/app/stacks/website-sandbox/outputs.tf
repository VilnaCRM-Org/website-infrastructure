# This is where you put your outputs declaration
output "sandbox_bucket_id" {
  description = "The name of the sandbox S3 bucket"
  value       = module.sandbox_bucket.bucket_id
}

output "sandbox_bucket_arn" {
  description = "The ARN of the sandbox S3 bucket"
  value       = module.sandbox_bucket.bucket_arn
}
