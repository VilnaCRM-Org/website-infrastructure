resource "aws_cloudwatch_log_group" "s3_lambda_notification_group" {
  #checkov:skip=CKV_AWS_338: The one year is too much 
  name              = "${var.project_name}-aws-s3-lambda-notification-group"
  retention_in_days = var.cloudwatch_log_group_retention_days
  kms_key_id        = aws_kms_key.cloudwatch_encryption_key.arn

  depends_on = [aws_kms_key_policy.cloudwatch_encryption_key]
}

resource "aws_cloudwatch_metric_alarm" "s3_objects_anomaly_detection" {
  alarm_name          = "${var.project_name}-s3-objects-anomaly-detection"
  comparison_operator = "LessThanLowerOrGreaterThanUpperThreshold"
  evaluation_periods  = 5
  threshold_metric_id = "e1"
  alarm_description   = "This metric monitors Anomaly Number of Objects in S3"
  alarm_actions       = [aws_sns_topic.bucket_notifications.arn]

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "Number of Objects (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "NumberOfObjects"
      namespace   = "AWS/S3"
      period      = 60
      stat        = "Average"
      unit        = "Count"

      dimensions = {
        BucketName  = aws_s3_bucket.this.id
        StorageType = "StandardStorage"
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "s3_requests_anomaly_detection" {
  alarm_name          = "${var.project_name}-s3-requests-anomaly-detection"
  comparison_operator = "LessThanLowerOrGreaterThanUpperThreshold"
  evaluation_periods  = 5
  threshold_metric_id = "e1"
  alarm_description   = "This metric monitors Anomaly Number of Requests in S3"
  alarm_actions       = [aws_sns_topic.bucket_notifications.arn]

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "Number of Requests (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "AllRequests"
      namespace   = "AWS/S3"
      period      = 60
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        BucketName  = aws_s3_bucket.this.id
        StorageType = "StandardStorage"
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "s3_4xx_errors_anomaly_detection" {
  alarm_name          = "${var.project_name}-s3-4xx-errors-anomaly-detection"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = 1
  threshold_metric_id = "e1"
  alarm_description   = "This metric monitors Anomaly 4xx-errors in S3"
  alarm_actions       = [aws_sns_topic.bucket_notifications.arn]

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "4xx-errors (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "4xxErrors"
      namespace   = "AWS/S3"
      period      = 60
      stat        = "Average"
      unit        = "Count"

      dimensions = {
        BucketName  = aws_s3_bucket.this.id
        StorageType = "StandardStorage"
      }
    }
  }
}
