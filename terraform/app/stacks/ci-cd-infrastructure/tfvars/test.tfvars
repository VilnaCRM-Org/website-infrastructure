project_name               = "website-test"
environment                = "test"
github_connection_name     = "Github"
secretsmanager_secret_name = "test/AWS/Website"
website_url                = "vilnacrmtest.com"
bucket_name                 = "vilnacrmtest.com"

tags = {
  Project     = "website-test"
  Environment = "test"
}

stage_input = [
  { name = "validate", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "ValidateOutput" },
  { name = "plan", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "ValidateOutput", output_artifacts = "PlanOutput" },
  { name = "up", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "PlanOutput", output_artifacts = "UpOutput" },
  { name = "content", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "ContentOutput" },
  { name = "healthcheck", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "UpOutput", output_artifacts = "HealthcheckOutput" },
  { name = "down", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "UpOutput", output_artifacts = "DownOutput" }
]
build_projects = [
  "validate",
  "plan",
  "up",
  "content",
  "healthcheck",
  "down"
]