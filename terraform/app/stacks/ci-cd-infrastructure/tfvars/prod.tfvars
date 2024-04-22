project_name               = "website-prod"
environment                = "prod"
github_connection_name     = "Github"
secretsmanager_secret_name = "prod/AWS/Website"
website_url                = "vilnacrm.com"
bucket_name                = "vilnacrm.com"

tags = {
  Project     = "website-prod"
  Environment = "prod"
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
  { name = "deploy", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "DeployOutput" },
  { name = "healthcheck", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "UpOutput", output_artifacts = "HealthcheckOutput" },
]

ci_cd_website_stage_input = [
  { name = "lint", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "LintOutput" },
  { name = "test", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "TestOutput" },
  { name = "deploy", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "DeployOutput" },
  { name = "healthcheck", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "HealthcheckOutput" },
  { name = "lighthouse", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "LighthouseOutput" },
]
