output "role_arn" {
  value       = aws_iam_role.codepipeline_role.arn
  description = "The ARN of the IAM Role"
}

output "terraform_role_arn" {
  value       = aws_iam_role.terraform_role.arn
  description = "The ARN of the Terraform Role"
}

output "role_name" {
  value       = aws_iam_role.codepipeline_role.name
  description = "The ARN of the IAM Role"
}