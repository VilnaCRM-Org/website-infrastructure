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
  treat_missing_data  = "notBreaching"
  dimensions = {
    Country = "RU"
    WebACL  = "wafv2-web-acl"
  }
}

resource "aws_cloudwatch_metric_alarm" "wafv2_high_rate_blocked_requests" {
  provider            = aws.us-east-1
  alarm_name          = "${var.project_name}-wafv2-high-rate-blocked-requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = 360
  statistic           = "Average"
  threshold           = 100
  alarm_actions       = [aws_sns_topic.cloudwatch_alarm_notifications.arn]
  actions_enabled     = true
  treat_missing_data  = "notBreaching"
  dimensions = {
    WebACL = "wafv2-web-acl"
  }
}

resource "aws_cloudwatch_metric_alarm" "wafv2_scanning_alarm" {
  provider            = aws.us-east-1
  alarm_name          = "${var.project_name}-wafv2-scanning-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = 60
  statistic           = "Average"
  threshold           = 20
  alarm_description   = "Alert on Scanning attempts"
  treat_missing_data  = "notBreaching"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.cloudwatch_alarm_notifications.arn]
  dimensions = {
    Rule   = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    WebACL = "wafv2-web-acl"
  }
}

resource "aws_cloudwatch_metric_alarm" "wafv2_bots_alarm" {
  provider            = aws.us-east-1
  alarm_name          = "${var.project_name}-wafv2-bots-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  threshold           = 50

  alarm_description = "Alert on Bots attempts"

  metric_query {
    id          = "e1"
    expression  = "m1+m2"
    label       = "WAFV2 Bot requests"
    return_data = "true"
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "SampleBlockedRequest"
      namespace   = "AWS/WAFV2"
      period      = 300
      stat        = "Average"
      dimensions = {
        VerificationStatus = "bot:unverified"
        WebACL             = "wafv2-web-acl"
        BotCategory        = "ALL_BOTS"
      }
    }
  }

  metric_query {
    id = "m2"
    metric {
      metric_name = "SampleBlockedRequest"
      namespace   = "AWS/WAFV2"
      period      = 300
      stat        = "Average"
      dimensions = {
        VerificationStatus = "bot:verified"
        WebACL             = "wafv2-web-acl"
        BotCategory        = "ALL_BOTS"
      }
    }
  }

  alarm_actions = [aws_sns_topic.cloudwatch_alarm_notifications.arn]
}

resource "aws_cloudwatch_metric_alarm" "cloudfront_requests_flood_alarm" {
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
  treat_missing_data  = "notBreaching"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.cloudwatch_alarm_notifications.arn]
  dimensions = {
    DistributionId = aws_cloudfront_distribution.this.id
    Region         = "Global"
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudfront_staging_500_errors" {
  provider            = aws.us-east-1
  alarm_name          = "${var.project_name}-cloudfront-staging-5xx-errors-alarm"
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
    DistributionId = aws_cloudfront_distribution.staging_cloudfront_distribution.id
    Region         = "Global"
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudfront_staging_origin_latency" {
  provider            = aws.us-east-1
  alarm_name          = "${var.project_name}-cloudfront-staging-origin-latency-alarm"
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
    DistributionId = aws_cloudfront_distribution.staging_cloudfront_distribution.id
    Region         = "Global"
  }
}