resource "aws_iam_policy" "github_token_secrets_access_policy" {
  name        = var.policy_name
  description = "Policy allowing access to GitHub token stored in Secrets Manager"

  tags = {
    Purpose     = "GitHub Token Rotation"
    ManagedBy   = "Terraform"
  }

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Effect   = "Allow",
        Resource = var.secret_arn
      }
    ]
  })
}