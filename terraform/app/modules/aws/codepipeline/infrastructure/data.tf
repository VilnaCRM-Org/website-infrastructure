locals {
  codepipeline_notifications_topic_name = "${var.project_name}-notifications"
  codepipeline_notifications_topic_arn  = "arn:${var.partition}:sns:${var.region}:${var.account_id}:${local.codepipeline_notifications_topic_name}"
}

data "aws_iam_policy_document" "codepipeline_topic_doc" {
  statement {
    sid     = "AllowSNSPublishIntoTopic"
    effect  = "Allow"
    actions = ["sns:Publish"]

    principals {
      type        = "Service"
      identifiers = ["codestar-notifications.amazonaws.com"]
    }

    resources = [local.codepipeline_notifications_topic_arn]
  }
}
