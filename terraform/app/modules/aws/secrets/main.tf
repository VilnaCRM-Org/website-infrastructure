resource "aws_secretsmanager_secret" "github_token" {
  #checkov:skip=CKV_AWS_149:The KMS encryption of GitHub token is not needed
  #checkov:skip=CKV2_AWS_57:Token rotation is performed by GitHub actions
  name        = "github-token"
  description = "GitHub token for automation"

  lifecycle {
    prevent_destroy = true
  }
}