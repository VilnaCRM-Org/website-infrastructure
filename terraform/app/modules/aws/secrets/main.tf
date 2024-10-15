resource "aws_secretsmanager_secret" "github_token" {
  name        = "github-token"
  description = "GitHub token for automation"

  lifecycle {
    prevent_destroy = true
  }
}