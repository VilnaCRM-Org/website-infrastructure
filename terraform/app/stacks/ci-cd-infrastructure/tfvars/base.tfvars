source_repo_owner         = "VilnaCRM-Org"
source_repo_name          = "website-infrastructure"
website_content_repo_name = "website"
source_repo_branch        = "2-set-up-the-frontend-production-infrastructure"
region                    = "eu-central-1"
ruby_version              = "3.2"
python_version            = "3.12"
nodejs_version            = "20"
script_dir                = "./aws/scripts"
create_slack_notification = true

ci_cd_infra_buildspecs = "ci-cd-infrastructure"

website_infra_buildspecs = "website"

ci_cd_website_buildspecs = "website-deploy"