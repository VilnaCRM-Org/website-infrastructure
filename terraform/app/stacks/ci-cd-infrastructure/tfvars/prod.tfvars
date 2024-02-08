project_name           = "website-prod"
environment            = "prod"
github_connection_name = "Github"
tags = {
  Project     = "website-prod"
  Environment = "prod"
}

stage_input = [
  { name = "validate", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "ValidateOutput" },
  { name = "plan", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "ValidateOutput", output_artifacts = "PlanOutput" },
  { name = "up", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "PlanOutput", output_artifacts = "UpOutput" }
]
build_projects = [
  "validate",
  "plan",
  "up"
]