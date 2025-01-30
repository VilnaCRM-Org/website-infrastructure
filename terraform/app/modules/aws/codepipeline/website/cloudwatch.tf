resource "aws_cloudwatch_log_group" "reports_notification_group" {
  #checkov:skip=CKV_AWS_338: The one year is too much
  #checkov:skip=CKV_AWS_158: KMS encryption is not needed
  name              = "${var.project_name}-aws-reports-notification-group"
  retention_in_days = var.cloudwatch_log_group_retention_days

}

resource "aws_cloudwatch_metric_alarm" "lambda_invocations_anomaly_detection" {
  alarm_name          = "${var.project_name}-lambda-reports-invocations-anomaly-detection"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = 1
  threshold_metric_id = "e1"
  alarm_description   = "This metric monitors Anomaly Lambda Invocations"
  alarm_actions       = [var.cloudwatch_alerts_sns_topic_arn]

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "Invocations (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "Invocations"
      namespace   = "AWS/Lambda"
      period      = 60
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        FunctionName = local.lambda_reports_notifications_function_name
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors_detection" {
  alarm_name          = "${var.project_name}-lambda-reports-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  unit                = "Count"
  threshold           = 1
  alarm_description   = "This metric monitors Lambda Errors"
  alarm_actions       = [var.cloudwatch_alerts_sns_topic_arn]
  dimensions = {
    FunctionName = local.lambda_reports_notifications_function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles_anomaly_detection" {
  alarm_name          = "${var.project_name}-lambda-reports-throttles-anomaly-detection"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = 1
  threshold_metric_id = "e1"
  alarm_description   = "This metric monitors Anomaly Lambda Throttles"
  alarm_actions       = [var.cloudwatch_alerts_sns_topic_arn]

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "Throttles (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "Throttles"
      namespace   = "AWS/Lambda"
      period      = 60
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        FunctionName = local.lambda_reports_notifications_function_name
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration_anomaly_detection" {
  alarm_name          = "${var.project_name}-lambda-reports-duration-anomaly-detection"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = 1
  threshold_metric_id = "e1"
  alarm_description   = "This metric monitors Anomaly Lambda Duration"
  alarm_actions       = [var.cloudwatch_alerts_sns_topic_arn]

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "Duration (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "Duration"
      namespace   = "AWS/Lambda"
      period      = 60
      stat        = "Average"
      unit        = "Milliseconds"

      dimensions = {
        FunctionName = local.lambda_reports_notifications_function_name
      }
    }
  }
}
