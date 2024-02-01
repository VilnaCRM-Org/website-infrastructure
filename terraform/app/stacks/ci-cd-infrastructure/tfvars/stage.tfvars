project_name           = "website-stage"
environment            = "stage"
github_connection_name = "Github"
tags = {
  Project     = "website-stage"
  Environment = "stage"
}

slack_workspace_id = ""
slack_channel_id   = ""

stage_input = [
  { name = "validate", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "ValidateOutput" },
  { name = "plan", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "ValidateOutput", output_artifacts = "PlanOutput" },
  { name = "up", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "PlanOutput", output_artifacts = "UpOutput" },
  { name = "ApproveDown", category = "Approval", owner = "AWS", provider = "Manual", input_artifacts = "PlanOutput", output_artifacts = "ApprovalOutput" },
  { name = "down", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "UpOutput", output_artifacts = "DownOutput" }
]

build_projects = [
  "validate",
  "plan",
  "up",
  "approvedown",
  "down"
]