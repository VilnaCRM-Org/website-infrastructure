resource "aws_cloudwatch_metric_alarm" "canary_alarm" {
  alarm_name          = "${var.project_name}-heartbeat-canary-2xx"
  comparison_operator = "LessThanThreshold"
  period              = "28800"
  evaluation_periods  = "1"
  metric_name         = "2xx"
  namespace           = "CloudWatchSynthetics"
  statistic           = "Sum"
  unit                = "Count"
  datapoints_to_alarm = "1"
  threshold           = "48"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarm_notifications.arn]
  alarm_description   = "Hearbeat Canary"
  dimensions = {
    CanaryName = local.canary_name
  }
}