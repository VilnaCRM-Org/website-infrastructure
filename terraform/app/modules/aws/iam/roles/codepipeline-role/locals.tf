locals {
  account_id               = data.aws_caller_identity.current.account_id
  is_ci_cd_infra           = var.project_name == "ci-cd-infra-${var.environment}" ? true : false
  is_website_infra         = var.project_name == "website-infra-${var.environment}" ? true : false
  policy_arns              = [for key, policy in var.policy_arns : policy.arn]
  ci_cd_infra_arns         = { for key, policy in var.policy_arns : key => policy if startswith(key, "ci_cd_infra_") }
  website_infra_arns       = { for key, policy in var.policy_arns : key => policy if startswith(key, "website_infra_") }
  website_bucket_arn       = "arn:aws:s3:::${var.website_bucket_name}"
  website_bucket_files_arn = "arn:aws:s3:::${var.website_bucket_name}/*"
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