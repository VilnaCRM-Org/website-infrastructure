resource "aws_cloudwatch_metric_alarm" "dynamodb_read_capacity_anomaly_detection" {
  alarm_name          = "${var.project_name}-dynamodb-read-capacity-anomaly-detection"
  comparison_operator = "LessThanLowerOrGreaterThanUpperThreshold"
  evaluation_periods  = 5
  threshold_metric_id = "e1"
  alarm_description   = "This metric monitors ConsumedReadCapacityUnits for DynamoDB"
  alarm_actions       = [var.cloudwatch_alerts_sns_topic_arn]

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "Consumed Read Capacity Units (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "ConsumedReadCapacityUnits"
      namespace   = "AWS/DynamoDB"
      period      = 60
      stat        = "Sum"
      unit        = "Count"
      dimensions = {
        TableName = var.dynamodb_table_name
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "dynamodb_write_capacity_anomaly_detection" {
  alarm_name          = "${var.project_name}-dynamodb-write-capacity-anomaly-detection"
  comparison_operator = "LessThanLowerOrGreaterThanUpperThreshold"
  evaluation_periods  = 5
  threshold_metric_id = "e1"
  alarm_description   = "This metric monitors Consumed Write Capacity Units for DynamoDB"
  alarm_actions       = [var.cloudwatch_alerts_sns_topic_arn]

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "Consumed Write Capacity Units (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "ConsumedWriteCapacityUnits"
      namespace   = "AWS/DynamoDB"
      period      = 60
      stat        = "Sum"
      unit        = "Count"
      dimensions = {
        TableName = var.dynamodb_table_name
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "dynamodb_system_errors_detection" {
  alarm_name          = "${var.project_name}-dynamodb-system-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/DynamoDB"
  period              = 60
  statistic           = "Sum"
  unit                = "Count"
  threshold           = 1
  alarm_description   = "This metric monitors System Errors of DynamoDB"
  alarm_actions       = [var.cloudwatch_alerts_sns_topic_arn]
  dimensions = {
    TableName = var.dynamodb_table_name
  }
}