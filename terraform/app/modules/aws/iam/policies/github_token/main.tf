resource "aws_iam_policy" "github_token_policy" {
  name        = "github-token-policy"
  description = "Policy to allow access to GitHub token"

  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
        ]
        Resource = [
          data.aws_secretsmanager_secret.github_token.arn,
        ]
      },
    ]
  })
}