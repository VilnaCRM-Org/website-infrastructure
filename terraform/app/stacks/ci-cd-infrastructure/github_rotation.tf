# GitHub Token Rotation and CodePipeline IAM Configuration
#
# This Terraform configuration manages the following components:
# - GitHub token storage in AWS Secrets Manager
# - IAM policy for GitHub token access
#

# Manages the GitHub token secret in AWS Secrets Manager for secure storage and rotation
module "github_token_secret" {
  source = "../../modules/aws/secrets"

  github_token = var.github_token_secret_name
}

#  Policies to allow GitHub token rotation
module "github_token_policy" {
  source = "../../modules/aws/iam/policies/github_token"
}