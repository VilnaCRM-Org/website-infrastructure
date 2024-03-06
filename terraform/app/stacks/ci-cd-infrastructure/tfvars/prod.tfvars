project_name               = "codepipeline-prod"
environment                = "prod"
github_connection_name     = "Github"
secretsmanager_secret_name = "prod/AWS/Website"
website_url                = "vilnacrm.com"

tags = {
  Project     = "website-prod"
  Environment = "prod"
}

stage_input = [
  { name = "validate", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "ValidateOutput" },
  { name = "plan", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "ValidateOutput", output_artifacts = "PlanOutput" },
  { name = "up", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "PlanOutput", output_artifacts = "UpOutput" },
  { name = "healthcheck", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "UpOutput", output_artifacts = "HealthcheckOutput" }
]
build_projects = [
  "validate",
  "plan",
  "up",
  "healthcheck"
]