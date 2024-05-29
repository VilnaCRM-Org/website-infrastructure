resource "aws_cloudwatch_metric_alarm" "cloudfront_500_errors" {
  provider            = aws.us-east-1
  alarm_name          = "${var.project_name}-cloudfront-5xx-errors-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarm_notifications.arn]
  actions_enabled     = true

  dimensions = {
    DistributionId = aws_cloudfront_distribution.this.id
    Region         = "Global"
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudfront_origin_latency" {
  provider            = aws.us-east-1
  alarm_name          = "${var.project_name}-cloudfront-origin-latency-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "OriginLatency"
  namespace           = "AWS/CloudFront"
  period              = 180
  statistic           = "Average"
  threshold           = 200
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.cloudwatch_alarm_notifications.arn]
  actions_enabled     = true

  dimensions = {
    DistributionId = aws_cloudfront_distribution.this.id
    Region         = "Global"
  }
}

resource "aws_cloudwatch_metric_alarm" "wafv2_country_blocked_requests" {
  provider            = aws.us-east-1
  alarm_name          = "${var.project_name}-wafv2-country-blocked-requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 10
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = 60
  statistic           = "Average"
  threshold           = 100
  alarm_actions       = [aws_sns_topic.cloudwatch_alarm_notifications.arn]
  actions_enabled     = true

  dimensions = {
    Country = "RU"
    WebACL  = "wafv2-web-acl"
  }
}

resource "aws_cloudwatch_metric_alarm" "wafv2_sql_injection_alarm" {
  provider            = aws.us-east-1
  alarm_name          = "${var.project_name}-wafv2-sql-injection-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = 60
  statistic           = "Average"
  threshold           = 10
  alarm_description   = "Alert on SQL injection attempts"

  alarm_actions = [aws_sns_topic.cloudwatch_alarm_notifications.arn]
    dimensions = {
    Rule = "AWS-AWSManagedRulesSQLiRuleSet"
    WebACL  = "wafv2-web-acl"
    }
}

resource "aws_cloudwatch_metric_alarm" "cloudfront_requests_flood" {
  provider            = aws.us-east-1
  alarm_name          = "${var.project_name}-cloudfront-requests-flood-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Requests"
  namespace           = "AWS/CloudFront"
  period              = 60
  statistic           = "Average"
  threshold           = 1000
  alarm_description   = "Alerts on HTTP Flood"

  alarm_actions = [aws_sns_topic.cloudwatch_alarm_notifications.arn]
  dimensions = {
    DistributionId = aws_cloudfront_distribution.this.id
    Region         = "Global"
  }
}