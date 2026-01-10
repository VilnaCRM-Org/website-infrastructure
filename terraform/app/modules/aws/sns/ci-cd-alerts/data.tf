locals {
  cloudwatch_alerts_topic_name = "${var.project_name}-cloudwatch-alerts-notifications"
  cloudwatch_alerts_topic_arn  = "arn:${var.partition}:sns:${var.region}:${var.account_id}:${local.cloudwatch_alerts_topic_name}"
}

data "aws_iam_policy_document" "cloudwatch_alerts_sns_topic_doc" {
  statement {
    sid     = "AllowSNSPublishIntoTopicForCloudWatch"
    effect  = "Allow"
    actions = ["sns:Publish"]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    resources = [local.cloudwatch_alerts_topic_arn]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = var.cloudwatch_alarms_arns
    }
  }
}
