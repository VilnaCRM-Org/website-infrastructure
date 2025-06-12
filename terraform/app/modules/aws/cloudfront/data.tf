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
        "${aws_cloudwatch_metric_alarm.cloudfront_500_errors.arn}",
        "${aws_cloudwatch_metric_alarm.cloudfront_origin_latency.arn}",
        "${aws_cloudwatch_metric_alarm.cloudfront_staging_500_errors.arn}",
        "${aws_cloudwatch_metric_alarm.cloudfront_staging_origin_latency.arn}",
        "${aws_cloudwatch_metric_alarm.cloudfront_requests_anomaly_detection.arn}",
        "${aws_cloudwatch_metric_alarm.wafv2_blocked_requests_anomaly_detection.arn}",
        "${aws_cloudwatch_metric_alarm.wafv2_country_blocked_requests.arn}",
        "${aws_cloudwatch_metric_alarm.cloudfront_requests_flood_alarm.arn}",
        "${aws_cloudwatch_metric_alarm.wafv2_high_rate_blocked_requests.arn}",
        "${aws_cloudwatch_metric_alarm.wafv2_scanning_alarm.arn}",
        "${aws_cloudwatch_metric_alarm.wafv2_bots_alarm.arn}",
      ]
    }
  }
}
