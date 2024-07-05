output "cloudwatch_alarms_arns" {
  value = [
    aws_cloudwatch_metric_alarm.dynamodb_write_capacity_anomaly_detection.arn,
    aws_cloudwatch_metric_alarm.dynamodb_read_capacity_anomaly_detection.arn,
    aws_cloudwatch_metric_alarm.dynamodb_system_errors_detection.arn,
  ]
}