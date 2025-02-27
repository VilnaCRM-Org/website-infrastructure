resource "aws_wafv2_web_acl" "waf_web_acl" {
  provider = aws.us-east-1
  name     = "wafv2-web-acl"
  scope    = "CLOUDFRONT"

  default_action {
    allow {
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "WAF_Common_Protections"
    sampled_requests_enabled   = true
  }

  rule {
    name     = local.waf_rules.common_rule
    priority = 0
    override_action {
      none {
      }
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          action_to_use {
            allow {}
          }

          name = "SizeRestrictions_BODY"
        }

        rule_action_override {
          action_to_use {
            allow {}
          }

          name = "NoUserAgent_HEADER"
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = local.waf_rules.common_rule
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = local.waf_rules.amazon_ip_reputation_rule
    priority = 2
    override_action {
      none {
      }
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = local.waf_rules.amazon_ip_reputation_rule
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = local.waf_rules.bad_inputs_rule
    priority = 5
    override_action {
      none {
      }
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = local.waf_rules.bad_inputs_rule
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = local.waf_rules.rate_limit_rule
    priority = 8

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 10000
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = local.waf_rules.rate_limit_rule
      sampled_requests_enabled   = true
    }
  }

  tags = var.tags

}

resource "aws_wafv2_web_acl_logging_configuration" "waf_web_acl_logging" {
  provider                = aws.us-east-1
  log_destination_configs = [aws_cloudwatch_log_group.waf_web_acl_log_group.arn]
  resource_arn            = aws_wafv2_web_acl.waf_web_acl.arn
  depends_on = [
    aws_wafv2_web_acl.waf_web_acl,
    aws_cloudwatch_log_group.waf_web_acl_log_group
  ]
}