mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = { json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}" }
  }
  mock_resource "aws_codepipeline" {
    defaults = { arn = "arn:aws:codepipeline:eu-central-1:123456789012:integration-pipeline" }
  }
  mock_resource "aws_sns_topic" {
    defaults = { arn = "arn:aws:sns:eu-central-1:123456789012:integration-notifications" }
  }
}

variables {
  project_name            = "integration"
  source_repo_owner       = "VilnaCRM-Org"
  source_repo_name        = "website-infrastructure"
  source_repo_branch      = "main"
  region                  = "eu-central-1"
  account_id              = "123456789012"
  partition               = "aws"
  s3_bucket_name          = "integration-artifacts"
  codepipeline_role_arn   = "arn:aws:iam::123456789012:role/integration"
  codestar_connection_arn = "arn:aws:codestar-connections:eu-central-1:123456789012:connection/00000000-0000-0000-0000-000000000000"
  tags                    = {}
  stages = [{
    name             = "validate"
    category         = "Test"
    owner            = "AWS"
    provider         = "CodeBuild"
    input_artifacts  = ["SourceOutput"]
    output_artifacts = "ValidateOutput"
  }]
}

run "ci_cd_filters_main_docs_only_pushes" {
  command = plan
  variables { detect_changes = "true" }

  assert {
    condition     = aws_codepipeline.terraform_pipeline.pipeline_type == "V2"
    error_message = "Infrastructure triggers require V2."
  }
  assert {
    condition     = one(aws_codepipeline.terraform_pipeline.stage[0].action).configuration["DetectChanges"] == "false"
    error_message = "The legacy source trigger must stay disabled when using V2 filters."
  }
  assert {
    condition     = toset(one(one(one(aws_codepipeline.terraform_pipeline.trigger).git_configuration).push).branches[0].includes) == toset(["main"])
    error_message = "Automatic CI/CD detection must remain limited to main."
  }
  assert {
    condition     = toset(one(one(one(aws_codepipeline.terraform_pipeline.trigger).git_configuration).push).file_paths[0].excludes) == toset(["README.md", "diagrams/**", "docs/**"])
    error_message = "Keep the main-branch documentation exclusions."
  }
}

run "website_infrastructure_requires_explicit_start" {
  command = plan
  variables { detect_changes = "false" }

  assert {
    condition     = length(aws_codepipeline.terraform_pipeline.trigger) == 0
    error_message = "Website infrastructure must not regain an independent source trigger."
  }
  assert {
    condition     = one(aws_codepipeline.terraform_pipeline.stage[0].action).configuration["DetectChanges"] == "false"
    error_message = "The source action must also disable automatic detection."
  }
  assert {
    condition     = aws_codepipeline.terraform_pipeline.pipeline_type == "V2"
    error_message = "The explicit source revision handoff requires V2."
  }
}
