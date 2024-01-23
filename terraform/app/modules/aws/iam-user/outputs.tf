output "access_key" {
  value = aws_iam_access_key.codepipeline_user_iam_access_key.id
}

output "secret_key" {
  value = aws_iam_access_key.codepipeline_user_iam_access_key.encrypted_secret
}
