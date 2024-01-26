project_name                = "vilnacrm-project"
environment                 = "prod"
source_repo_owner           = "VilnaCRM-Org"
source_repo_name            = "website-infrastructure"
source_repo_branch          = "2-set-up-the-frontend-production-infrastructure"
github_connection_name      = "github-connect"
kms_condition_account_value = "Account"
tags = {
  Project     = "vilnacrm-project"
  Environment = "prod"
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