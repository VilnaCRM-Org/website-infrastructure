locals {
  account_id     = data.aws_caller_identity.current.account_id
  is_ci_cd_infra = var.project_name == "ci-cd-infra-${var.environment}" ? true : false
  policy_arns    = [for key, policy in var.policy_arns : policy.arn]
  ci_cd_arns     = { for k, p in var.policy_arns : k => p if startswith(k, "ci_cd_") }
}