resource "aws_cloudwatch_log_group" "waf_web_acl_log_group" {
  #checkov:skip=CKV_AWS_338: The one year is too much 
  provider          = aws.us-east-1
  name              = "aws-waf-logs-wafv2-web-acl"
  retention_in_days = 60
  kms_key_id        = aws_kms_key.cloudwatch_encryption_key.arn

  depends_on = [aws_kms_key.cloudwatch_encryption_key]
}

resource "aws_cloudwatch_metric_alarm" "cloudfront-500-errors" {
  provider            = aws.us-east-1
  alarm_name          = "${var.project_name}-AWS-CloudFront-High-5xx-Error-Rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = 60
  statistic           = "Average"
  threshold           = 5
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarm_notifications.arn]
  actions_enabled     = true

  dimensions = {
    DistributionId = aws_cloudfront_distribution.this.id
    Region         = "Global"
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudfront-origin-latency" {
  provider            = aws.us-east-1
  alarm_name          = "${var.project_name}-AWS-CloudFront-Origin-Latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "OriginLatency"
  namespace           = "AWS/CloudFront"
  period              = 60
  statistic           = "Average"
  threshold           = 5
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarm_notifications.arn]
  actions_enabled     = true

  dimensions = {
    DistributionId = aws_cloudfront_distribution.this.id
    Region         = "Global"
  }
}