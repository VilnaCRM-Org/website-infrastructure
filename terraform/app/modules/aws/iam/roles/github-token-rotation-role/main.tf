data "aws_caller_identity" "current" {}

resource "aws_iam_role" "github_actions_role" {
  name = var.github_actions_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        },
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com",
            "token.actions.githubusercontent.com:sub" = "repo:${var.source_repo_owner}/${var.source_repo_name}:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}