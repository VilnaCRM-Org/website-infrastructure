locals {
  source_change_detection_enabled = lower(var.detect_changes) == "true"
}

resource "aws_codepipeline" "terraform_pipeline" {
  #checkov:skip=CKV_AWS_219: S3 bucket has encryption by default
  name     = "${var.project_name}-pipeline"
  role_arn = var.codepipeline_role_arn
  tags     = var.tags

  pipeline_type = "V2"

  artifact_store {
    location = var.s3_bucket_name
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Download-Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      namespace        = "SourceVariables"
      output_artifacts = ["SourceOutput"]
      run_order        = 1

      configuration = {
        ConnectionArn    = var.codestar_connection_arn
        FullRepositoryId = "${var.source_repo_owner}/${var.source_repo_name}"
        BranchName       = var.source_repo_branch
        DetectChanges    = local.source_change_detection_enabled ? "false" : var.detect_changes
      }
    }
  }

  dynamic "trigger" {
    for_each = local.source_change_detection_enabled ? [var.source_repo_branch] : []

    content {
      provider_type = "CodeStarSourceConnection"

      git_configuration {
        source_action_name = "Download-Source"

        push {
          branches {
            includes = [trigger.value]
          }
        }
      }
    }
  }

  dynamic "stage" {
    for_each = var.stages

    content {
      name = "Stage-${stage.value.name}"
      action {
        category         = stage.value.category
        name             = "Action-${stage.value.name}"
        owner            = stage.value.owner
        provider         = stage.value.provider
        input_artifacts  = stage.value.input_artifacts
        output_artifacts = [stage.value.output_artifacts]
        version          = "1"
        run_order        = index(var.stages, stage.value) + 2

        configuration = {
          ProjectName   = stage.value.provider == "CodeBuild" ? "${var.project_name}-${stage.value.name}" : null
          PrimarySource = stage.value.provider == "CodeBuild" && length(stage.value.input_artifacts) > 1 ? stage.value.input_artifacts[0] : null
        }
      }
    }
  }
}

resource "aws_codestarnotifications_notification_rule" "codepipeline_rule" {
  detail_type = "BASIC"
  event_type_ids = [
    "codepipeline-pipeline-pipeline-execution-failed",
    "codepipeline-pipeline-pipeline-execution-canceled",
    "codepipeline-pipeline-pipeline-execution-started",
    "codepipeline-pipeline-pipeline-execution-resumed",
    "codepipeline-pipeline-pipeline-execution-succeeded",
    "codepipeline-pipeline-pipeline-execution-superseded",
  ]

  name     = "${var.project_name}-notifications"
  resource = aws_codepipeline.terraform_pipeline.arn

  target {
    address = aws_sns_topic.codepipeline_notifications.arn
  }

  tags = var.tags
}
