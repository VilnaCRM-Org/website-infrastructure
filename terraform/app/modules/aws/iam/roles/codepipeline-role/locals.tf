locals {
  account_id     = data.aws_caller_identity.current.account_id
  is_ci_cd_infra = var.project_name == "ci-cd-infra-${var.environment}" ? true : false
  policy_arns    = [for key, policy in var.policy_arns : policy.arn]
  ci_cd_arns     = { for key, policy in var.policy_arns : key => policy if startswith(key, "ci_cd_") }
  website_arns   = { for key, policy in var.policy_arns : key => policy if startswith(key, "website_") }
}