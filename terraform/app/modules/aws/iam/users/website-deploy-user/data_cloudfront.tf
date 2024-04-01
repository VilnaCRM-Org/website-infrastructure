data "aws_iam_policy_document" "cloudfront_policy_doc" {
  statement {
    sid    = "CloudfrontHeadersPolicyForWebsiteUser"
    effect = "Allow"
    actions = [
      "cloudfront:CreateResponseHeadersPolicy",
      "cloudfront:GetResponseHeadersPolicy",
      "cloudfront:DeleteResponseHeadersPolicy"
    ]
    resources = [
      "arn:aws:cloudfront::${local.account_id}:response-headers-policy/*"
    ]
  }
  statement {
    sid    = "CloudfrontOriginAccessPolicyForWebsiteUser"
    effect = "Allow"
    actions = [
      "cloudfront:GetOriginAccessControl",
      "cloudfront:DeleteOriginAccessControl"
    ]
    resources = [
      "arn:aws:cloudfront::${local.account_id}:response-headers-policy/*",
      "arn:aws:cloudfront::${local.account_id}:origin-access-control/*"
    ]
  }
  statement {
    sid    = "CloudfrontDistributionPolicyForWebsiteUser"
    effect = "Allow"
    actions = [
      "cloudfront:CreateDistribution",
      "cloudfront:CreateDistributionWithTags",
      "cloudfront:GetDistribution",
      "cloudfront:ListTagsForResource",
      "cloudfront:UpdateDistribution",
      "cloudfront:TagResource",
      "cloudfront:DeleteDistribution"
    ]
    resources = [
      "arn:aws:cloudfront::${local.account_id}:distribution/*"
    ]
  }
  statement {
    sid    = "WAFV2CloudfrontCreationPolicyForWebsiteUser"
    effect = "Allow"
    actions = [
      "wafv2:CreateWebACL",
      "wafv2:GetWebACL",
      "wafv2:DeleteWebACL"
    ]
    resources = [
      "arn:aws:wafv2:us-east-1:${local.account_id}:CLOUDFRONT/ipset/wafv2-web-acl/*",
      "arn:aws:wafv2:us-east-1:${local.account_id}:CLOUDFRONT/managedruleset/wafv2-web-acl/*",
      "arn:aws:wafv2:us-east-1:${local.account_id}:CLOUDFRONT/regexpatternset/wafv2-web-acl/*",
      "arn:aws:wafv2:us-east-1:${local.account_id}:CLOUDFRONT/rulegroup/wafv2-web-acl/*",
      "arn:aws:wafv2:us-east-1:${local.account_id}:CLOUDFRONT/webacl/wafv2-web-acl/*",
    ]
  }
  statement {
    sid    = "WAFV2GlobalCreationPolicyForWebsiteUser"
    effect = "Allow"
    actions = [
      "wafv2:CreateWebACL",
      "wafv2:GetWebACL",
      "wafv2:DeleteWebACL"
    ]
    resources = [
      "arn:aws:wafv2:us-east-1:${local.account_id}:global/managedruleset/*/*",
      "arn:aws:wafv2:us-east-1:${local.account_id}:global/webacl/wafv2-web-acl/*"
    ]
  }
  statement {
    sid    = "WAFV2GetDeletePolicyForWebsiteUser"
    effect = "Allow"
    actions = [
      "wafv2:GetWebACL",
      "wafv2:DeleteWebACL"
    ]
    resources = [
      "arn:aws:wafv2:us-east-1:${local.account_id}:CLOUDFRONT/webacl/wafv2-web-acl/*"
    ]
  }
  statement {
    sid    = "WAFV2LoggingPolicyForWebsiteUser"
    effect = "Allow"
    actions = [
      "wafv2:AssociateWebACL",
      "wafv2:ListTagsForResource",
      "wafv2:PutLoggingConfiguration",
      "wafv2:GetLoggingConfiguration",
      "wafv2:DeleteLoggingConfiguration",
      "wafv2:TagResource"
    ]
    resources = [
      "arn:aws:wafv2:us-east-1:${local.account_id}:global/webacl/wafv2-web-acl/*",
    ]
  }
  statement {
    sid    = "CloudwatchPolicyForWebsiteUser"
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:ListTagsForResource",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:DeleteAlarms"
    ]
    resources = [
      "arn:aws:cloudwatch:us-east-1:${local.account_id}:alarm:website-test-AWS-CloudFront-High-5xx-Error-Rate",
      "arn:aws:cloudwatch:us-east-1:${local.account_id}:alarm:website-test-AWS-CloudFront-Origin-Latency"
    ]
  }
  statement {
    sid    = "LogsPolicyForWebsiteUser"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogDelivery",
      "logs:DescribeResourcePolicies",
      "logs:ListTagsLogGroup",
      "logs:GetLogEvents",
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy",
      "logs:PutResourcePolicy",
      "logs:DeleteLogGroup",
      "logs:DeleteLogDelivery"
    ]
    resources = [
      "arn:aws:logs:us-east-1:${local.account_id}:log-group:aws-waf-logs-wafv2-web-acl:*"
    ]
  }
} 