data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

resource "aws_iam_policy" "github_token_secrets_access_policy" {
  name        = var.policy_name
  description = "Policy allowing access to GitHub token stored in Secrets Manager"

  tags = {
    Purpose   = "GitHub Token Rotation"
    ManagedBy = "Terraform"
  }

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowSecretsManagerAccessForGithubToken"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Effect   = "Allow",
        Resource = ["arn:${data.aws_partition.current.partition}:secretsmanager:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:secret:github-token-*"]
      },
      {
        Sid      = "AllowListingSecrets"
        Action   = "secretsmanager:ListSecrets",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}