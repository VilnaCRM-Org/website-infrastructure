data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_iam_policy_document" "codepipeline_sns_kms_key_policy_doc" {
  statement {
    sid     = "EnableRootAccessAndPreventPermissionDelegationForCodePipelineSNSKMSKey"
    effect  = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:ReEncrypt",
      "kms:DescribeKey",
      "kms:ListAliases",
      "kms:ListGrants",
      "kms:CreateGrant",
      "kms:RevokeGrant"
    ]
    #checkov:skip=CKV_AWS_356:Without this statement, KMS key cannot be managed by root
    resources = ["${aws_kms_key.codepipeline_sns_encryption_key.arn}"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }

  statement {
    sid       = "AllowAccessForKeyAdministratorsForCodePipelineSNSKMSKey"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["${aws_kms_key.codepipeline_sns_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "${aws_sns_topic.codepipeline_notifications.arn}"
      ]
    }
  }
  statement {
    sid    = "AllowUseOfTheKeyForCodePipelineSNSKMSKey"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*"
    ]

    resources = ["${aws_kms_key.codepipeline_sns_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "${aws_sns_topic.codepipeline_notifications.arn}"
      ]
    }
  }
  statement {
    sid    = "AllowUseOfTheKeyForCodeStarNotificationKMSKey"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey*",
      "kms:Decrypt"
    ]

    resources = ["${aws_kms_key.codepipeline_sns_encryption_key.arn}"]

    principals {
      type        = "Service"
      identifiers = ["codestar-notifications.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "sns.${var.region}.amazonaws.com"
      ]
    }
  }
}

# resource "aws_codestarnotifications_notification_rule" "pipeline_rule" {
#   name        = "${var.project_name}-pipeline-notification-rule"
#   detail_type = "FULL"
#   resource    = aws_codepipeline.pipeline.arn

#   event_type_ids = [
#     "codepipeline-pipeline-pipeline-execution-failed",
#     "codepipeline-pipeline-pipeline-execution-canceled",
#     "codepipeline-pipeline-pipeline-execution-started",
#     "codepipeline-pipeline-pipeline-execution-resumed",
#     "codepipeline-pipeline-pipeline-execution-succeeded",
#   ]

#   target {
#     address = awscc_chatbot_slack_channel_configuration.slack_channel_configuration.arn
#     type    = "AWSChatbotSlack"
#   }

#   tags = var.tags
# }

# module "iam_role_module" {
#   source       = "../../chatbot"
#   project_name     = var.project_name
#   channel_id       = var.channel_id
#   workspace_id     = var.workspace_id
#   sns_topic_arns   = var.sns_topic_arns
#   tags             = var.tags
# }
