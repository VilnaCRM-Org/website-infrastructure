module "ci_cd_website_s3_artifacts_bucket" {
  source = "../../modules/aws/s3/codepipeline"

  project_name = var.ci_cd_website_project_name

  region      = var.region
  environment = var.environment

  s3_artifacts_bucket_files_deletion_days = var.s3_artifacts_bucket_files_deletion_days

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

  s3_bucket_arn                  = module.ci_cd_website_s3_artifacts_bucket.arn
  codestar_connection_arn        = module.codestar_connection.arn
  lhci_reports_bucket_arn        = module.lhci_reports_bucket.arn
  test_reports_bucket_bucket_arn = module.test_reports_bucket.arn

  tags = var.tags
}

module "ci_cd_website_codebuild" {
  source = "../../modules/aws/codebuild/stages"

  project_name   = var.ci_cd_website_project_name
  build_projects = local.ci_cd_website_build_projects

  region      = var.region
  environment = var.environment

  s3_bucket_name = module.ci_cd_website_s3_artifacts_bucket.bucket
  role_arn       = module.ci_cd_website_codepipeline_iam_role.role_arn


  tags = var.tags

  depends_on = [
    module.ci_cd_website_s3_artifacts_bucket,
    module.ci_cd_website_codepipeline_iam_role,
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
  cloudwatch_log_group_retention_days   = var.cloudwatch_log_group_retention_days

  stages = var.ci_cd_website_stage_input

  region = var.region

  s3_bucket_name                  = module.ci_cd_website_s3_artifacts_bucket.bucket
  codepipeline_role_arn           = module.ci_cd_website_codepipeline_iam_role.role_arn
  codestar_connection_arn         = module.codestar_connection.arn
  cloudwatch_alerts_sns_topic_arn = module.cloudwatch_alerts_sns.cloudwatch_alerts_sns_topic_arn

  tags = var.tags

  depends_on = [module.ci_cd_website_codebuild, module.ci_cd_website_s3_artifacts_bucket]
}

module "ci_cd_pipeline_role" {
  source       = "../../modules/aws/iam/oidc/pipeline-trigger-role"
  role_name    = "${var.website_content_repo_name}-deploy-trigger-role"
  github_owner = var.source_repo_owner
  github_repo  = var.source_repo_name
  website_repo = var.website_content_repo_name
  branch       = var.source_repo_branch
  pipeline_arn = module.ci_cd_website_codepipeline.arn
}