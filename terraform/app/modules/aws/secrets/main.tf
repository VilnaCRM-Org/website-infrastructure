resource "random_string" "secret_hash" {
  length  = 8
  special = false
  upper   = false
  numeric = true
}

resource "aws_secretsmanager_secret" "github_token" {
  #checkov:skip=CKV_AWS_149:The KMS encryption of GitHub token is not needed
  #checkov:skip=CKV2_AWS_57:Token rotation is performed by GitHub actions
  name = "${var.github_token_secret_name}-${random_string.secret_hash.result}"
  description = "GitHub token for automation"
}