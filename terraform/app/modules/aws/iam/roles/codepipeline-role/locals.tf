locals {
  account_id          = data.aws_caller_identity.current.account_id
  create_users_policy = var.project_name == "ci-cd-infra-${var.environment}" ? true : false
}