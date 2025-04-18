resource "aws_codepipeline" "pipeline" {
  # checkov:skip=CKV_AWS_219: S3 bucket has encryption by default
  name     = var.codepipeline_name
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
        DetectChanges    = var.detect_changes
      }
    }
  }

  dynamic "stage" {
    for_each = var.stages

    content {
      name = "Stage-${stage.value["name"]}"

      action {
        category         = stage.value["category"]
        name             = "Action-${stage.value["name"]}"
        owner            = stage.value["owner"]
        provider         = stage.value["provider"]
        input_artifacts  = [stage.value["input_artifacts"]]
        output_artifacts = [stage.value["output_artifacts"]]
        version          = "1"
        run_order        = index(var.stages, stage.value) + 2

        configuration = merge(
          {
            EnvironmentVariables = jsonencode([
              {
                name  = "BRANCH_NAME"
                value = "#{variables.BRANCH_NAME}"
                type  = "PLAINTEXT"
              },
              {
                name  = "PR_NUMBER"
                value = "#{variables.PR_NUMBER}"
                type  = "PLAINTEXT"
              },
              {
                name  = "IS_PULL_REQUEST"
                value = "#{variables.IS_PULL_REQUEST}"
                type  = "PLAINTEXT"
              },
            ])
          },
          stage.value["provider"] == "CodeBuild" ? {
            ProjectName = "${var.project_name}-${stage.value["name"]}"
          } : {}
        )
      }
    }
  }

  variable {
    name          = "BRANCH_NAME"
    default_value = var.BRANCH_NAME
    description   = "Name of the Branch"
  }

  variable {
    name          = "PR_NUMBER"
    default_value = var.PR_NUMBER
    description   = "Number of the Pull request"
  }

  variable {
    name          = "IS_PULL_REQUEST"
    default_value = var.IS_PULL_REQUEST ? "1" : "0"
    description   = "Is it Pull Request"
  }
}

resource "aws_codestarnotifications_notification_rule" "codepipeline_sns_rule" {
  detail_type = "BASIC"
  event_type_ids = [
    "codepipeline-pipeline-pipeline-execution-failed",
    "codepipeline-pipeline-pipeline-execution-canceled",
    "codepipeline-pipeline-pipeline-execution-started",
    "codepipeline-pipeline-pipeline-execution-resumed",
    "codepipeline-pipeline-pipeline-execution-succeeded",
    "codepipeline-pipeline-pipeline-execution-superseded",
  ]

  name     = "${var.project_name}-${var.notification_rule_suffix}-sns-notifications"
  resource = aws_codepipeline.pipeline.arn

  target {
    address = aws_sns_topic.codepipeline_notifications.arn
  }

  tags = var.tags

  depends_on = [aws_sns_topic.codepipeline_notifications]
}
