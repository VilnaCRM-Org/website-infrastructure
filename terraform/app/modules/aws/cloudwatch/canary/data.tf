data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}


data "aws_iam_policy_document" "cloudwatch_alarm_sns_topic_doc" {
  statement {
    sid     = "AllowSNSPublishIntoTopicForCloudWatch"
    effect  = "Allow"
    actions = ["sns:Publish"]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    resources = ["${aws_sns_topic.cloudwatch_alarm_notifications.arn}"]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "${aws_cloudwatch_metric_alarm.canary_alarm.arn}",
      ]
    }
  }
}
