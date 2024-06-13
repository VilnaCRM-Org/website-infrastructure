source_repo_owner         = "VilnaCRM-Org"
source_repo_name          = "website-infrastructure"
website_content_repo_name = "website"
source_repo_branch        = "2-set-up-the-frontend-production-infrastructure"
website_repo_branch       = "5-make-website-layout"
region                    = "eu-central-1"

cloudfront_configuration = {
  region = "us-east-1"

}
continuous_deployment_policy_weight = 0.15
continuous_deployment_policy_header = "staging"

script_dir = "./aws/scripts"

dynamodb_table_name = "terraform_locks"

lambda_python_version                 = "python3.12"
lambda_reserved_concurrent_executions = -1

s3_artifacts_bucket_files_deletion_days = 7

cloudwatch_log_group_retention_days = 7

create_slack_notification = true

runtime_versions = {
  ruby   = "3.2"
  python = "3.12"
  nodejs = "20"
  golang = "1.21"
}

s3_logs_lifecycle_configuration = {
  standard_ia_transition_days  = 30
  glacier_transition_days      = 60
  deep_archive_transition_days = 150
  deletion_days                = 365
}

codebuild_environment = {
  default_build_project_source                = "CODEPIPELINE"
  default_builder_compute_type                = "BUILD_GENERAL1_SMALL"
  default_builder_type                        = "LINUX_CONTAINER"
  default_builder_image_pull_credentials_type = "CODEBUILD"
  amazonlinux2_builder_image                  = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  ubuntu_builder_image                        = "aws/codebuild/standard:7.0"
}

ci_cd_infra_buildspecs = "ci-cd-infrastructure"

website_infra_buildspecs = "website"

ci_cd_website_buildspecs = "ci-cd-website"