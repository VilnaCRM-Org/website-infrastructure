source_repo_owner         = "VilnaCRM-Org"
source_repo_name          = "website-infrastructure"
source_repo_branch        = "2-set-up-the-frontend-production-infrastructure"
region                    = "eu-central-1"
ruby_version              = "3.2"
python_version            = "3.12"
nodejs_version            = "20"
script_dir                = "./aws/scripts"
create_slack_notification = true

ci_cd_infra_buildspecs = "ci-cd-infrastructure"

ci_cd_infra_stage_input = [
  { name = "validate", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "ValidateOutput" },
  { name = "plan", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "ValidateOutput", output_artifacts = "PlanOutput" },
  { name = "up", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "PlanOutput", output_artifacts = "UpOutput" },
]
ci_cd_infra_build_projects = [
  "validate",
  "plan",
  "up",
]

website_infra_buildspecs = "website"

website_infra_stage_input = [
  { name = "validate", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "ValidateOutput" },
  { name = "plan", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "ValidateOutput", output_artifacts = "PlanOutput" },
  { name = "up", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "PlanOutput", output_artifacts = "UpOutput" },
  { name = "deploy", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "DeployOutput" },
  { name = "healthcheck", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "UpOutput", output_artifacts = "HealthcheckOutput" },
  { name = "down", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "UpOutput", output_artifacts = "DownOutput" }
]

website_infra_build_projects = [
  "validate",
  "plan",
  "up",
  "deploy",
  "healthcheck",
  "down"
]

website_deploy_buildspecs = "website"

website_deploy_stage_input = [
  { name = "deploy", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "DeployOutput" },
  { name = "healthcheck", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "HealthcheckOutput"}
]

website_deploy_build_projects = [
  "deploy",
  "healthcheck",
]