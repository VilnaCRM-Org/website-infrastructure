resource "aws_codepipeline" "sandbox_pipeline" {
  name     = "sandbox-deletion-pipeline"
  role_arn = var.codepipeline_role_arn

  pipeline_type = "V2"

  artifact_store {
    type     = "S3"
    location = var.s3_bucket_arn
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn    = var.codestar_connection_arn
        FullRepositoryId = "${var.source_repo_owner}/${var.source_repo_name}"
        BranchName       = var.source_repo_branch
      }
    }
  }

stage {
  name = "Delete"

  action {
    name             = "Delete"
    category         = "Build"
    owner            = "AWS"
    provider         = "CodeBuild"
    version          = "1"
    input_artifacts  = ["source_output"]
    configuration = {
        ProjectName = var.codebuild_project_name
      }
  }
}
}