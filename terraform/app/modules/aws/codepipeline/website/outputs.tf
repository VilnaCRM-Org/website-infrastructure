output "id" {
  value       = aws_codepipeline.terraform_pipeline.id
  description = "The id of the CodePipeline"
}

output "name" {
  value       = aws_codepipeline.terraform_pipeline.name
  description = "The name of the CodePipeline"
}

output "arn" {
  value       = aws_codepipeline.terraform_pipeline.arn
  description = "The arn of the CodePipeline"
}

output "codepipeline_sns_topic_arn" {
  value       = aws_sns_topic.codepipeline_notifications.arn
  description = "The SNS Topic Arn of the CodePipeline"
}


output "reports_sns_topic_arn" {
  value       = aws_sns_topic.reports_notifications.arn
  description = "The SNS Topic Arn of the CodePipeline"
}

output "cloudwatch_reports_sns_topic_arn" {
  value       = aws_sns_topic.cloudwatch_reports_notifications.arn
  description = "The SNS Topic Arn of the CodePipeline"
}
