locals {
  account_id               = data.aws_caller_identity.current.account_id
  is_ci_cd_infra           = var.project_name == "ci-cd-infra-${var.environment}" ? true : false
  is_website_infra         = var.project_name == "website-infra-${var.environment}" ? true : false
  policy_arns              = [for key, policy in var.policy_arns : policy.arn]
  ci_cd_infra_arns         = { for key, policy in var.policy_arns : key => policy if startswith(key, "ci_cd_infra_") }
  website_infra_arns       = { for key, policy in var.policy_arns : key => policy if startswith(key, "website_infra_") }
  website_bucket_arn       = "arn:aws:s3:::${var.website_bucket_name}"
  website_bucket_files_arn = "arn:aws:s3:::${var.website_bucket_name}/*"
  replication_policy_arns = [
    "arn:aws:iam::${local.account_id}:policy/${var.website_bucket_name}-iam-role-policy-replication",
    "arn:aws:iam::${local.account_id}:policy/staging.${var.website_bucket_name}-iam-role-policy-replication",
  ]
  terraform_iam_managed_policy_arns = [
    "arn:aws:iam::${local.account_id}:policy/CodePipelinePolicies/${var.environment}-*",
    "arn:aws:iam::${local.account_id}:policy/CodePipelinePolicies/*-${var.environment}-*",
    "arn:aws:iam::${local.account_id}:policy/WebsitePolicies/${var.environment}-website-user-*",
    "arn:aws:iam::${local.account_id}:policy/DevOpsPolicies/${var.environment}-devops-group-*",
    "arn:aws:iam::${local.account_id}:policy/QAPolicies/${var.environment}-qa-group-*",
    "arn:aws:iam::${local.account_id}:policy/FrontendPolicies/${var.environment}-frontend-group-*",
    "arn:aws:iam::${local.account_id}:policy/BackendPolicies/${var.environment}-backend-group-*",
    "arn:aws:iam::${local.account_id}:policy/AdminPolicies/${var.environment}-admin-group-iam-policy",
  ]
  codepipeline_role_policy_resources = [
    "arn:aws:iam::${local.account_id}:policy/ci-cd-infra-${var.environment}-*",
    "arn:aws:iam::${local.account_id}:policy/ci-cd-website-${var.environment}-*",
    "arn:aws:iam::${local.account_id}:policy/website-infra-${var.environment}-*",
    "arn:aws:iam::${local.account_id}:policy/ci-cd-infra-trigger-role-policy",
    "arn:aws:iam::${local.account_id}:role/website-infrastructure-trigger-role",
    "arn:aws:iam::${local.account_id}:role/website-deploy-trigger-role",
    "arn:aws:iam::${local.account_id}:role/sandbox-deletion-trigger-role",
    "arn:aws:iam::${local.account_id}:role/sandbox-creation-trigger-role",
    "arn:aws:iam::${local.account_id}:role/ci-cd-infra-trigger-role",
    "arn:aws:iam::${local.account_id}:role/github-actions-role",
  ]
}

locals {
  ci_cd_infra_codepipeline_policy_bucket_access = [
    "${var.s3_bucket_arn}/*",
    "${var.s3_bucket_arn}"
  ]
  website_infra_codepipeline_policy_bucket_access = [
    "${var.s3_bucket_arn}/*",
    "${var.s3_bucket_arn}",
    "${local.website_bucket_arn}",
    "${local.website_bucket_files_arn}"
  ]
}
