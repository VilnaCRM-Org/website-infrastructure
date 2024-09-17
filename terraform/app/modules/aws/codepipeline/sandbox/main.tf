resource "aws_codepipeline" "pipeline" {
  name     = "${var.project_name}-pipeline"
  role_arn = var.codepipeline_role_arn
  tags     = var.tags

  pipeline_type = "V2"

  artifact_store {
    location = var.s3_bucket_name
    type     = "S3"
    encryption_key {
      id   = var.kms_key_arn
      type = "KMS"
    }
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

        configuration = {
          ProjectName = stage.value["provider"] == "CodeBuild" ? "${var.project_name}-${stage.value["name"]}" : null
          EnvironmentVariables = jsonencode(
            [
              {
                name : "BRANCH_NAME",
                value : "#{variables.BRANCH_NAME}",
                type : "PLAINTEXT"
              },
              {
                name : "PR_NUMBER",
                value : "#{variables.PR_NUMBER}",
                type : "PLAINTEXT"
              },
              {
                name : "IS_PULL_REQUEST",
                value : "#{variables.IS_PULL_REQUEST}",
                type : "PLAINTEXT"
              }
            ]
          )
        }
      }
    }
  }

  variable {
    name          = "BRANCH_NAME"
    default_value = "6-implement-sandbox-workflows"
    description   = "Name of the Branch"
  }

  variable {
    name          = "PR_NUMBER"
    default_value = "1000"
    description   = "Number of the Pull request"
  }

  variable {
    name          = "IS_PULL_REQUEST"
    default_value = "0"
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

  name     = "${var.project_name}-notifications"
  resource = aws_codepipeline.pipeline.arn

  target {
    address = aws_sns_topic.codepipeline_notifications.arn
  }

  tags = var.tags
}


module "chatbot" {
  source          = "../../chatbot"
  project_name    = var.project_name
  channel_id      = var.channel_id
  workspace_id    = var.workspace_id
  sns_topic_arns  = var.sns_topic_arns
  tags            = var.tags
}

resource "aws_codestarnotifications_notification_rule" "codepipeline_rule" {
  detail_type = "FULL"
  event_type_ids = [
    "codepipeline-pipeline-pipeline-execution-failed",
    "codepipeline-pipeline-pipeline-execution-canceled",
    "codepipeline-pipeline-pipeline-execution-started",
    "codepipeline-pipeline-pipeline-execution-resumed",
    "codepipeline-pipeline-pipeline-execution-succeeded",
    "codepipeline-pipeline-pipeline-execution-superseded",
  ]

  name     = "${var.project_name}-notifications"
  resource = aws_codepipeline.pipeline.arn

  target {
    address = module.chatbot.slack_channel_configuration_arn
    type    = "AWSChatbotSlack"
  }
}