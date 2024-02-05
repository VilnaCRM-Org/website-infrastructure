project_name           = "website-dev"
environment            = "dev"
github_connection_name = "Github"
tags = {
  Project     = "website-dev"
  Environment = "dev"
}

slack_workspace_id = ""
slack_channel_id   = ""

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