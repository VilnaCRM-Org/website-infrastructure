locals {
  account_id = data.aws_caller_identity.current.account_id
  ci_cd_website_codebuild_project_arns = [
    for stage_name in var.ci_cd_website_stage_names :
    "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.ci_cd_website_project_name}-${stage_name}"
  ]
}
