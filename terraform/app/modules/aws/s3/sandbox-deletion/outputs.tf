output "codepipeline_bucket_arn" {
  value = aws_s3_bucket.codepipeline_bucket.arn
}

output "codebuild_logs_bucket_arn" {
  value = aws_s3_bucket.codebuild_logs_bucket.arn
}

output "access_logs_bucket_arn" {
  value = aws_s3_bucket.access_logs_bucket.arn
}

output "codepipeline_bucket_name" {
  value = aws_s3_bucket.codepipeline_bucket.bucket
}

output "codebuild_logs_bucket_name" {
  value = aws_s3_bucket.codebuild_logs_bucket.bucket
}