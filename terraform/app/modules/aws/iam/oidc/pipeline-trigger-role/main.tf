data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"

  # Each exact subject gets a statement of its own: condition keys inside one
  # statement are ANDed, so a StringEquals sub beside the StringLike sub list
  # below would require a token to match both and would lock out every caller.
  environment_subject_statements = [
    for subject in var.environment_subjects : {
      Effect = "Allow"
      Principal = {
        Federated = local.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = subject
        }
      }
    }
  ]
}

resource "aws_iam_role" "codepipeline_trigger_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect = "Allow"
        Principal = {
          Federated = local.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/*",
              "repo:${var.github_owner}/${var.github_repo}:pull_request",
              "repo:${var.github_owner}/${var.website_repo}:ref:refs/heads/*",
              "repo:${var.github_owner}/${var.website_repo}:pull_request"
            ]
          }
        }
      }
    ], local.environment_subject_statements)
  })
}
