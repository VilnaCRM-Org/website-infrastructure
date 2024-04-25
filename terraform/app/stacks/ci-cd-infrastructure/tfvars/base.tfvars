source_repo_owner         = "VilnaCRM-Org"
source_repo_name          = "website-infrastructure"
website_content_repo_name = "website"
source_repo_branch        = "2-set-up-the-frontend-production-infrastructure"
region                    = "eu-central-1"
ruby_version              = "3.2"
python_version            = "3.12"
nodejs_version            = "20"
golang_version            = "1.21"
script_dir                = "./aws/scripts"
create_slack_notification = true

lambda_python_version                 = "python3.12"
lambda_reserved_concurrent_executions = -1

default_build_project_source                = "CODEPIPELINE"
default_builder_compute_type                = "BUILD_GENERAL1_SMALL"
default_builder_type                        = "LINUX_CONTAINER"
default_builder_image_pull_credentials_type = "CODEBUILD"

amazonlinux2_builder_image = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
ubuntu_builder_image       = "aws/codebuild/standard:7.0"

ci_cd_infra_buildspecs = "ci-cd-infrastructure"

website_infra_buildspecs = "website"

ci_cd_website_buildspecs = "ci-cd-website"