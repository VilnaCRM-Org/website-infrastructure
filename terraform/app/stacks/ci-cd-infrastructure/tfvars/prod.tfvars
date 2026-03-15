project_name               = "website-prod"
website_infra_project_name = "website-infra-prod"
ci_cd_infra_project_name   = "ci-cd-infra-prod"
ci_cd_website_project_name = "ci-cd-website-prod"
sandbox_project_name       = "sandbox-prod"
environment                = "prod"
github_connection_name     = "Github"
source_repo_branch         = "main"
website_repo_branch        = "main"
website_url                = "vilnacrm.com"
bucket_name                = "vilnacrm.com"

tags = {
  Project     = "website-prod"
  Environment = "prod"
}

s3_artifacts_bucket_files_deletion_days = 1

s3_logs_lifecycle_configuration = {
  standard_ia_transition_days  = 0
  glacier_transition_days      = 0
  deep_archive_transition_days = 0
  deletion_days                = 1
}

cloudwatch_log_group_retention_days = 1

enable_cloudwatch_alarms  = false
# Keep CloudFront staging enabled so prod rollouts retain the safer traffic-shift path.
enable_cloudfront_staging = true

ci_cd_infra_stage_input = [
  { name = "validate", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = ["SourceOutput"], output_artifacts = "ValidateOutput" },
  { name = "plan", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = ["SourceOutput"], output_artifacts = "PlanOutput" },
  { name = "up", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = ["SourceOutput", "PlanOutput"], output_artifacts = "UpOutput" },
]

website_infra_stage_input = [
  { name = "validate", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = ["SourceOutput"], output_artifacts = "ValidateOutput" },
  { name = "plan", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = ["SourceOutput"], output_artifacts = "PlanOutput" },
  { name = "up", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = ["SourceOutput", "PlanOutput"], output_artifacts = "UpOutput" },
]

ci_cd_website_stage_input = [
  { name = "deploy", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = ["SourceOutput"], output_artifacts = "DeployOutput" },
  { name = "healthcheck", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = ["SourceOutput"], output_artifacts = "HealthcheckOutput" },
  { name = "release", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = ["SourceOutput"], output_artifacts = "ReleaseOutput" },
]

sandbox_stage_input = [
  { name = "up", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = ["SourceOutput"], output_artifacts = "UpOutput" },
  { name = "deploy", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = ["SourceOutput"], output_artifacts = "DeployOutput" },
  { name = "healthcheck", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = ["SourceOutput"], output_artifacts = "HealthcheckOutput" },
]

sandbox_deletion_stage_input = [
  { name = "delete", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = ["SourceOutput"], output_artifacts = "DeleteOutput" },
]
