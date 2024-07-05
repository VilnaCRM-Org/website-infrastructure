locals {
  s3_origin_id          = "${var.domain_name}-orgin-id"
  s3_failover_origin_id = "${var.domain_name}-failover-orgin-id"
  account_id            = data.aws_caller_identity.current.account_id

  waf_rules = {
    common_rule               = "AWS-AWSManagedRulesCommonRuleSet"
    linux_rule                = "AWS-AWSManagedRulesLinuxRuleSet"
    amazon_ip_reputation_rule = "AWS-AWSManagedRulesAmazonIpReputationList"
    anonymous_rule            = "AWS-AWSManagedRulesAnonymousIpList"
    sql_rule                  = "AWS-AWSManagedRulesSQLiRuleSet"
    bad_inputs_rule           = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    unix_rule                 = "AWS-AWSManagedRulesUnixRuleSet"
    windows_rule              = "AWS-AWSManagedRulesWindowsRuleSet"
    rate_limit_rule           = "AWS-RateLimitRuleSet"
  }
}