output "codepipeline_role_arn" {
  value = aws_iam_role.codepipeline_role_sandbox.arn
}

output "codebuild_role_arn" {
  value = aws_iam_role.codebuild_role_sandbox.arn
}