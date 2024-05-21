resource "aws_cloudwatch_metric_alarm" "canary_alarm" {
  alarm_name          = "${var.project_name}-heartbeat-canary"
  comparison_operator = "LessThanThreshold"
  period              = "28800" // 8 hours (should be calculated from the frequency of the canary)
  evaluation_periods  = "1"
  metric_name         = "SuccessPercent"
  namespace           = "CloudWatchSynthetics"
  statistic           = "Sum"
  datapoints_to_alarm = "1"
  threshold           = "90"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarm_notifications.arn]
  alarm_description   = "Hearbeat Canary"
}