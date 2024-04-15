project_name                = "website-test"
website_infra_project_name  = "website-infra-test"
ci_cd_infra_project_name    = "ci-cd-infra-test"
ci_cd_website_project_name = "ci-cd-website-test"
environment                 = "test"
github_connection_name      = "Github"
secretsmanager_secret_name  = "test/AWS/Website"
website_url                 = "vilnacrmtest.com"
bucket_name                 = "vilnacrmtest.com"

tags = {
  Project     = "website-test"
  Environment = "test"
}

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

ci_cd_website_stage_input = [
  { name = "deploy", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "DeployOutput" },
  { name = "healthcheck", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "HealthcheckOutput" }
]

ci_cd_website_build_projects = [
  "deploy",
  "healthcheck",
]