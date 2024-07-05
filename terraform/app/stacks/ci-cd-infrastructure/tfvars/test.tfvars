project_name               = "website-test"
website_infra_project_name = "website-infra-test"
ci_cd_infra_project_name   = "ci-cd-infra-test"
ci_cd_website_project_name = "ci-cd-website-test"
environment                = "test"
github_connection_name     = "Github"
source_repo_branch         = "3-implement-sandbox-infrastructure"
website_repo_branch        = "5-make-website-layout"
website_url                = "vilnacrmtest.com"
bucket_name                = "vilnacrmtest.com"

tags = {
  Project     = "website-test"
  Environment = "test"
}

ci_cd_infra_stage_input = [
  { name = "validate", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "ValidateOutput" },
  { name = "plan", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "ValidateOutput", output_artifacts = "PlanOutput" },
  { name = "up", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "PlanOutput", output_artifacts = "UpOutput" },
]

website_infra_stage_input = [
  { name = "validate", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "ValidateOutput" },
  { name = "plan", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "ValidateOutput", output_artifacts = "PlanOutput" },
  { name = "up", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "PlanOutput", output_artifacts = "UpOutput" },
]

ci_cd_website_stage_input = [
  { name = "batch-unit-mutation-lint", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "UnitMutationLintOutput" },
  { name = "deploy", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "DeployOutput" },
  { name = "healthcheck", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "HealthcheckOutput" },
  { name = "batch-lhci-leak", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "LHCILeakOutput" },
  { name = "batch-pw-load", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "PWLoadOutput" },
  { name = "release", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "ReleaseOutput" },
  { name = "trigger", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "TriggerOutput" },
]
