resource "aws_codepipeline" "terraform_pipeline" {

  name     = "${var.project_name}-pipeline"
  role_arn = var.codepipeline_role_arn
  tags     = var.tags

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
        DetectChanges    = "true"
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
        }
      }
    }
  }
}

resource "aws_sns_topic" "codepipeline_notifications" {
  name = "${var.project_name}-codepipeline-notifications"

  kms_master_key_id = aws_kms_key.codepipeline_sns_encryption_key.id

  tags = var.tags

  depends_on = [aws_codepipeline.terraform_pipeline, aws_kms_key.codepipeline_sns_encryption_key]
}

resource "aws_sns_topic_policy" "codepipeline_notifications" {
  arn    = aws_sns_topic.codepipeline_notifications.arn
  policy = data.aws_iam_policy_document.codepipeline_topic_doc.json

  depends_on = [aws_sns_topic.codepipeline_notifications]
}

resource "aws_kms_key" "codepipeline_sns_encryption_key" {
  description             = "This key is used to encrypt codepipeline objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_kms_key_policy" "codepipeline_sns_encryption_key" {
  key_id = aws_kms_key.codepipeline_sns_encryption_key.key_id
  policy = data.aws_iam_policy_document.codepipeline_sns_kms_key_policy_doc.json

  depends_on = [aws_kms_key.codepipeline_sns_encryption_key]
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
    "codepipeline-pipeline-stage-execution-started",
    "codepipeline-pipeline-stage-execution-succeeded",
    "codepipeline-pipeline-stage-execution-resumed",
    "codepipeline-pipeline-stage-execution-canceled",
    "codepipeline-pipeline-stage-execution-failed"
  ]

  name     = "${var.project_name}-notifications"
  resource = aws_codepipeline.terraform_pipeline.arn

  target {
    address = aws_sns_topic.codepipeline_notifications.arn
  }

  tags = var.tags
}
