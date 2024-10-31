output "codepipeline_bucket_arn" {
  description = "ARN of the S3 bucket used for storing CodePipeline artifacts"
  value       = aws_s3_bucket.codepipeline_bucket.arn
}

output "codebuild_logs_bucket_arn" {
  description = "ARN of the S3 bucket used for storing CodeBuild logs"
  value       = aws_s3_bucket.codebuild_logs_bucket.arn
}

output "access_logs_bucket_arn" {
  description = "ARN of the S3 bucket used for storing access logs"
  value       = aws_s3_bucket.access_logs_bucket.arn
}

output "codepipeline_bucket_name" {
  description = "Name of the S3 bucket used for storing CodePipeline artifacts"
  value       = aws_s3_bucket.codepipeline_bucket.bucket
}

output "codebuild_logs_bucket_name" {
  description = "Name of the S3 bucket used for storing CodeBuild logs"
  value       = aws_s3_bucket.codebuild_logs_bucket.bucket
}

output "access_logs_bucket_name" {
  description = "Name of the S3 bucket used for storing access logs"
  value       = aws_s3_bucket.access_logs_bucket.bucket
}