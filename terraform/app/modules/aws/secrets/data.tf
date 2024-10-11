data "aws_secretsmanager_secret" "github_token" {
  name = "github-token"
}