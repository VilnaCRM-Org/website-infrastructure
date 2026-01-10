locals {
  s3_origin_id          = "${var.domain_name}-orgin-id"
  s3_failover_origin_id = "${var.domain_name}-failover-orgin-id"
  account_id            = data.aws_caller_identity.current.account_id

  waf_rules = {
    common_rule               = "AWS-AWSManagedRulesCommonRuleSet"
    amazon_ip_reputation_rule = "AWS-AWSManagedRulesAmazonIpReputationList"
    bad_inputs_rule           = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    rate_limit_rule           = "AWS-RateLimitRuleSet"
  }

  cloudfront_minimum_protocol_version = lookup(
    var.cloudfront_configuration,
    "minimum_protocol_version",
    "TLSv1.2_2021"
  )
}
