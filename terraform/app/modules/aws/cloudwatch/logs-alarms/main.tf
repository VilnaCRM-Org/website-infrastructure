resource "aws_cloudwatch_metric_alarm" "incoming_bytes_anomaly_detection" {
  alarm_name          = "logs-incoming-bytes-anomaly-detection"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
  threshold_metric_id = "e1"
  alarm_description   = "This metric monitors Anomaly Lambda Duration"
  alarm_actions       = [var.cloudwatch_alerts_sns_topic_arn]

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "Incoming Bytes (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "IncomingBytes"
      namespace   = "AWS/Logs"
      period      = 60
      stat        = "Average"
      unit        = "Bytes"
    }
  }
}
