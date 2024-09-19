# Outputs for the sandbox S3 bucket
output "sandbox_bucket_id" {
  description = "The name of the sandbox S3 bucket"
  value       = module.sandbox_bucket.id
}

output "sandbox_bucket_arn" {
  description = "The ARN of the sandbox S3 bucket"
  value       = module.sandbox_bucket.arn
}
