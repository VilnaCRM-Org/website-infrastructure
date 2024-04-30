module "codestar_connection" {
  source = "../../modules/aws/codestar"

  github_connection_name = var.github_connection_name

  tags = var.tags
}

module "ci_cd_infra_policies" {
  source = "../../modules/aws/iam/policies/codepipeline"

  policy_prefix              = "${var.environment}-ci-cd-infra"
  website_project_name       = var.website_infra_project_name
  ci_cd_project_name         = var.ci_cd_infra_project_name
  ci_cd_website_project_name = var.ci_cd_website_project_name
  region                     = var.region
  environment                = var.environment

  tags = var.tags
}

module "website_infra_policies" {
  source = "../../modules/aws/iam/policies/website"

  project_name  = var.project_name
  policy_prefix = "${var.environment}-website-infra"
  region        = var.region
  environment   = var.environment
  domain_name   = var.website_url

  tags = var.tags
}

module "ci_cd_infra_s3_artifacts_bucket" {
  source = "../../modules/aws/s3/codepipeline"

  project_name = var.ci_cd_infra_project_name

  region      = var.region
  environment = var.environment

  s3_bucket_files_deletion_days = var.s3_bucket_files_deletion_days

  kms_key_arn           = module.ci_cd_infra_codepipeline_kms.arn
  codepipeline_role_arn = module.ci_cd_infra_codepipeline_iam_role.role_arn

  tags = var.tags
}

module "ci_cd_infra_codepipeline_kms" {
  source = "../../modules/aws/kms"

  codepipeline_role_arn = module.ci_cd_infra_codepipeline_iam_role.role_arn

  tags = var.tags
}

module "ci_cd_infra_codepipeline_iam_role" {
  source = "../../modules/aws/iam/roles/codepipeline-role"

  project_name = var.ci_cd_infra_project_name

  codepipeline_iam_role_name = "${var.ci_cd_infra_project_name}-codepipeline-role"
  source_repo_owner          = var.source_repo_owner
  source_repo_name           = var.source_repo_name

  region      = var.region
  environment = var.environment

  website_bucket_name = var.bucket_name

  kms_key_arn             = module.ci_cd_infra_codepipeline_kms.arn
  s3_bucket_arn           = module.ci_cd_infra_s3_artifacts_bucket.arn
  codestar_connection_arn = module.codestar_connection.arn

  policy_arns = merge(module.ci_cd_infra_policies.policy_arns, module.website_infra_policies.policy_arns)

  tags = var.tags

  depends_on = [module.ci_cd_infra_policies]
}

module "ci_cd_infra_codebuild" {
  source = "../../modules/aws/codebuild"

  project_name   = var.ci_cd_infra_project_name
  build_projects = local.ci_cd_infra_build_projects

  s3_bucket_name = module.ci_cd_infra_s3_artifacts_bucket.bucket
  role_arn       = module.ci_cd_infra_codepipeline_iam_role.role_arn
  kms_key_arn    = module.ci_cd_infra_codepipeline_kms.arn

  codepipeline_buildspecs = var.ci_cd_infra_buildspecs

  region      = var.region
  environment = var.environment

  tags = var.tags

  depends_on = [
    module.ci_cd_infra_s3_artifacts_bucket,
    module.ci_cd_infra_codepipeline_iam_role,
    module.ci_cd_infra_codepipeline_kms,
    module.codestar_connection
  ]
}

module "ci_cd_infra_codepipeline" {
  source = "../../modules/aws/codepipeline/infrastructure"

  project_name       = var.ci_cd_infra_project_name
  source_repo_owner  = var.source_repo_owner
  source_repo_name   = var.source_repo_name
  source_repo_branch = var.source_repo_branch
  detect_changes     = "true"

  stages = var.ci_cd_infra_stage_input

  region = var.region

  s3_bucket_name          = module.ci_cd_infra_s3_artifacts_bucket.bucket
  codepipeline_role_arn   = module.ci_cd_infra_codepipeline_iam_role.role_arn
  kms_key_arn             = module.ci_cd_infra_codepipeline_kms.arn
  codestar_connection_arn = module.codestar_connection.arn

  tags = var.tags

  depends_on = [module.ci_cd_infra_codebuild, module.ci_cd_infra_s3_artifacts_bucket]
}

module "website_infra_s3_artifacts_bucket" {
  source = "../../modules/aws/s3/codepipeline"

  project_name = var.website_infra_project_name

  region      = var.region
  environment = var.environment

  s3_bucket_files_deletion_days = var.s3_bucket_files_deletion_days

  kms_key_arn           = module.website_infra_codepipeline_kms.arn
  codepipeline_role_arn = module.website_infra_codepipeline_iam_role.role_arn

  tags = var.tags
}

module "website_infra_codepipeline_kms" {
  source = "../../modules/aws/kms"

  codepipeline_role_arn = module.website_infra_codepipeline_iam_role.role_arn

  tags = var.tags
}

module "website_infra_codepipeline_iam_role" {
  source = "../../modules/aws/iam/roles/codepipeline-role"

  project_name               = var.website_infra_project_name
  codepipeline_iam_role_name = "${var.website_infra_project_name}-codepipeline-role"

  source_repo_owner = var.source_repo_owner
  source_repo_name  = var.source_repo_name

  region      = var.region
  environment = var.environment

  website_bucket_name = var.bucket_name

  kms_key_arn             = module.website_infra_codepipeline_kms.arn
  s3_bucket_arn           = module.website_infra_s3_artifacts_bucket.arn
  codestar_connection_arn = module.codestar_connection.arn

  policy_arns = module.website_infra_policies.policy_arns

  tags = var.tags

  depends_on = [module.website_infra_policies]
}

module "website_infra_codebuild" {
  source = "../../modules/aws/codebuild"

  project_name   = var.website_infra_project_name
  build_projects = local.website_infra_build_projects

  region      = var.region
  environment = var.environment

  codepipeline_buildspecs = var.website_infra_buildspecs

  s3_bucket_name = module.website_infra_s3_artifacts_bucket.bucket
  role_arn       = module.website_infra_codepipeline_iam_role.role_arn
  kms_key_arn    = module.website_infra_codepipeline_kms.arn

  tags = var.tags

  depends_on = [
    module.website_infra_s3_artifacts_bucket,
    module.website_infra_codepipeline_iam_role,
    module.website_infra_codepipeline_kms,
    module.codestar_connection
  ]
}

module "website_infra_codepipeline" {
  source = "../../modules/aws/codepipeline/infrastructure"

  project_name       = var.website_infra_project_name
  source_repo_owner  = var.source_repo_owner
  source_repo_name   = var.source_repo_name
  source_repo_branch = var.source_repo_branch
  detect_changes     = "true"

  stages = var.website_infra_stage_input

  region = var.region

  s3_bucket_name          = module.website_infra_s3_artifacts_bucket.bucket
  codepipeline_role_arn   = module.website_infra_codepipeline_iam_role.role_arn
  kms_key_arn             = module.website_infra_codepipeline_kms.arn
  codestar_connection_arn = module.codestar_connection.arn

  tags = var.tags

  depends_on = [module.website_infra_codebuild, module.website_infra_s3_artifacts_bucket]
}

module "lhci_reports_bucket" {
  source = "../../modules/aws/s3/reports"

  project_name = "${var.ci_cd_website_project_name}-lhci"

  s3_bucket_files_deletion_days = var.s3_bucket_files_deletion_days

  tags = var.tags
}

module "test_reports_bucket" {
  source = "../../modules/aws/s3/reports"

  project_name = "${var.ci_cd_website_project_name}-test"

  s3_bucket_files_deletion_days = var.s3_bucket_files_deletion_days

  tags = var.tags
}

module "ci_cd_website_s3_artifacts_bucket" {
  source = "../../modules/aws/s3/codepipeline"

  project_name = var.ci_cd_website_project_name

  region      = var.region
  environment = var.environment

  s3_bucket_files_deletion_days = var.s3_bucket_files_deletion_days

  kms_key_arn           = module.ci_cd_website_codepipeline_kms.arn
  codepipeline_role_arn = module.ci_cd_website_codepipeline_iam_role.role_arn

  tags = var.tags
}

module "ci_cd_website_codepipeline_kms" {
  source = "../../modules/aws/kms"

  codepipeline_role_arn = module.ci_cd_website_codepipeline_iam_role.role_arn

  tags = var.tags
}

module "ci_cd_website_codepipeline_iam_role" {
  source = "../../modules/aws/iam/roles/ci-cd-website-codepipeline-role"

  project_name               = var.ci_cd_website_project_name
  codepipeline_iam_role_name = "${var.ci_cd_website_project_name}-codepipeline-role"

  source_repo_owner = var.source_repo_owner
  source_repo_name  = var.source_repo_name

  website_bucket_name = var.bucket_name

  region      = var.region
  environment = var.environment

  kms_key_arn                    = module.ci_cd_website_codepipeline_kms.arn
  s3_bucket_arn                  = module.ci_cd_website_s3_artifacts_bucket.arn
  codestar_connection_arn        = module.codestar_connection.arn
  lhci_reports_bucket_arn        = module.lhci_reports_bucket.arn
  test_reports_bucket_bucket_arn = module.test_reports_bucket.arn

  tags = var.tags
}

module "ci_cd_website_codebuild" {
  source = "../../modules/aws/codebuild"

  project_name   = var.ci_cd_website_project_name
  build_projects = local.ci_cd_website_build_projects

  region      = var.region
  environment = var.environment

  codepipeline_buildspecs = var.website_infra_buildspecs

  s3_bucket_name = module.ci_cd_website_s3_artifacts_bucket.bucket
  role_arn       = module.ci_cd_website_codepipeline_iam_role.role_arn
  kms_key_arn    = module.ci_cd_website_codepipeline_kms.arn


  tags = var.tags

  depends_on = [
    module.ci_cd_website_s3_artifacts_bucket,
    module.ci_cd_website_codepipeline_iam_role,
    module.ci_cd_website_codepipeline_kms,
    module.codestar_connection
  ]
}

module "ci_cd_website_codepipeline" {
  source = "../../modules/aws/codepipeline/website"

  project_name       = var.ci_cd_website_project_name
  source_repo_owner  = var.source_repo_owner
  source_repo_name   = var.source_repo_name
  source_repo_branch = var.source_repo_branch
  detect_changes     = "false"

  lambda_python_version                 = var.lambda_python_version
  lambda_reserved_concurrent_executions = var.lambda_reserved_concurrent_executions

  stages = var.ci_cd_website_stage_input

  region = var.region

  s3_bucket_name          = module.ci_cd_website_s3_artifacts_bucket.bucket
  codepipeline_role_arn   = module.ci_cd_website_codepipeline_iam_role.role_arn
  kms_key_arn             = module.ci_cd_website_codepipeline_kms.arn
  codestar_connection_arn = module.codestar_connection.arn

  tags = var.tags

  depends_on = [module.ci_cd_website_codebuild, module.ci_cd_website_s3_artifacts_bucket]
}

module "oidc_role" {
  source = "../../modules/aws/iam/oidc/codepipeline"

  project_name      = var.ci_cd_website_project_name
  source_repo_owner = var.source_repo_owner
  source_repo_name  = var.source_repo_name

  ci_cd_website_codepipeline_arn  = module.ci_cd_website_codepipeline.arn
  ci_cd_website_codepipeline_name = module.ci_cd_website_codepipeline.name

  tags = var.tags

  depends_on = [module.ci_cd_website_codepipeline]
}

module "chatbot_codepipelines" {
  count = var.create_slack_notification ? 1 : 0

  source = "../../modules/aws/chatbot"

  project_name = "codepipeline"
  channel_id   = var.CODEPIPELINE_SLACK_CHANNEL_ID
  workspace_id = var.SLACK_WORKSPACE_ID

  sns_topic_arns = [
    module.website_infra_codepipeline.sns_topic_arn,
    module.ci_cd_infra_codepipeline.sns_topic_arn,
    module.ci_cd_website_codepipeline.codepipeline_sns_topic_arn,
  ]

  tags = var.tags

  depends_on = [
    module.website_infra_codepipeline,
    module.ci_cd_infra_codepipeline,
    module.ci_cd_website_codepipeline
  ]
}

module "chatbot_reports" {
  count = var.create_slack_notification ? 1 : 0

  source = "../../modules/aws/chatbot"

  project_name = "reports"
  channel_id   = var.REPORT_SLACK_CHANNEL_ID
  workspace_id = var.SLACK_WORKSPACE_ID

  sns_topic_arns = [
    module.ci_cd_website_codepipeline.reports_sns_topic_arn
  ]

  tags = var.tags

  depends_on = [
    module.ci_cd_website_codepipeline
  ]
}