resource "github_actions_secret" "aws_trigger_user_access_key" {
  repository      = var.repository_name
  secret_name     = "AWS_PIPELINE_ACCESS_KEY"
  encrypted_value = base64encode(var.access_key)
}

resource "github_actions_secret" "aws_trigger_user_secret_key" {
  repository      = var.repository_name
  secret_name     = "AWS_PIPELINE_SECRET_KEY"
  encrypted_value = base64encode(var.secret_key)
}

resource "github_actions_secret" "aws_codepipeline_name" {
  repository      = var.repository_name
  secret_name     = "AWS_CODEPIPELINE_NAME"
  encrypted_value = base64encode(var.codepipeline_name)
}