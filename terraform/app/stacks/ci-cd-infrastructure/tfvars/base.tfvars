source_repo_owner           = "VilnaCRM-Org"
source_repo_name            = "website-infrastructure"
source_repo_branch          = "2-set-up-the-frontend-production-infrastructure"
kms_condition_account_value = "Account"

project_name           = "website-test"
environment            = "test"
github_connection_name = "Github"
tags = {
  Project     = "website-test"
  Environment = "test"
}

stage_input = [
  { name = "validate", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "ValidateOutput" },
  { name = "plan", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "ValidateOutput", output_artifacts = "PlanOutput" },
  { name = "up", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "PlanOutput", output_artifacts = "UpOutput" },
  { name = "down", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "UpOutput", output_artifacts = "DownOutput" }
]

build_projects = [
  "validate",
  "plan",
  "up",
  "down"
]