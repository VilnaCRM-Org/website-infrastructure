resource "aws_cloudwatch_metric_alarm" "cloudfront_requests_anomaly_detection" {
  provider            = aws.us-east-1
  alarm_name          = "${var.project_name}-cloudfront-requests-anomaly-detection"
  comparison_operator = "LessThanLowerOrGreaterThanUpperThreshold"
  evaluation_periods  = 5
  threshold_metric_id = "e1"
  alarm_description   = "This metric monitors Anomaly Requests in CloudFront"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarm_notifications.arn]

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "Requests (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "Requests"
      namespace   = "AWS/CloudFront"
      period      = 60
      stat        = "Average"

      dimensions = {
        DistributionId = aws_cloudfront_distribution.this.id
        Region         = "Global"
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudfront_bytes_downloaded_anomaly_detection" {
  provider            = aws.us-east-1
  alarm_name          = "${var.project_name}-cloudfront-bytes-downloaded-anomaly-detection"
  comparison_operator = "LessThanLowerOrGreaterThanUpperThreshold"
  evaluation_periods  = 5
  threshold_metric_id = "e1"
  alarm_description   = "This metric monitors Anomaly Bytes Downloaded in CloudFront"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarm_notifications.arn]

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "Bytes Downloaded (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "BytesDownloaded"
      namespace   = "AWS/CloudFront"
      period      = 60
      stat        = "Average"

      dimensions = {
        DistributionId = aws_cloudfront_distribution.this.id
        Region         = "Global"
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "wafv2_allowed_requests_anomaly_detection" {
  provider            = aws.us-east-1
  alarm_name          = "${var.project_name}-wafv2-allowed-requests-anomaly-detection"
  comparison_operator = "LessThanLowerOrGreaterThanUpperThreshold"
  evaluation_periods  = 5
  threshold_metric_id = "e1"
  alarm_description   = "This metric monitors WAFV2 Allowed Requests"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarm_notifications.arn]

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "WAFV2 Allowed Requests (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "AllowedRequests"
      namespace   = "AWS/WAFV2"
      period      = 60
      stat        = "Average"
      dimensions = {
        Rule   = "ALL"
        WebACL = "wafv2-web-acl"
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "wafv2_blocked_requests_anomaly_detection" {
  provider            = aws.us-east-1
  alarm_name          = "${var.project_name}-wafv2-blocked-requests-anomaly-detection"
  comparison_operator = "LessThanLowerOrGreaterThanUpperThreshold"
  evaluation_periods  = 5
  threshold_metric_id = "e1"
  alarm_description   = "This metric monitors WAFV2 Blocked Requests"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarm_notifications.arn]

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "WAFV2 Blocked Requests (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "BlockedRequests"
      namespace   = "AWS/WAFV2"
      period      = 60
      stat        = "Average"
      dimensions = {
        Rule   = "ALL"
        WebACL = "wafv2-web-acl"
      }
    }
  }
}