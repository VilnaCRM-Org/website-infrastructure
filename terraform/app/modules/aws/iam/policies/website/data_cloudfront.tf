data "aws_iam_policy_document" "cloudfront_policy_doc" {
  statement {
    sid    = "CloudfrontHeadersPolicy"
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
    sid    = "CloudfrontCachePolicy"
    effect = "Allow"
    actions = [
      "cloudfront:ListCachePolicies",
      "cloudfront:GetCachePolicy",
      "cloudfront:UpdateCachePolicy",
      "cloudfront:CreateCachePolicy",
    ]
    resources = [
      "arn:aws:cloudfront::${local.account_id}:cache-policy/*"
    ]
  }

  statement {
    sid    = "CloudfrontOriginAccessPolicy"
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
    sid    = "CloudfrontDistributionPolicy"
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
    sid    = "CloudfrontContinuousDeploymentPolicy"
    effect = "Allow"
    actions = [
      "cloudfront:CreateContinuousDeploymentPolicy",
    ]
    resources = [
      "arn:aws:cloudfront::${local.account_id}:continuous-deployment-policy/*"
    ]
  }
  statement {
    sid    = "WAFV2CloudfrontCreationPolicy"
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
    sid    = "WAFV2GlobalCreationPolicy"
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
    sid    = "WAFV2GetDeletePolicy"
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
    sid    = "WAFV2LoggingPolicy"
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
    sid    = "CloudwatchPolicy"
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:ListTagsForResource",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:DeleteAlarms"
    ]
    resources = [
      "arn:aws:cloudwatch:us-east-1:${local.account_id}:alarm:${var.project_name}-wafv2-allowed-requests-anomaly-detection",
      "arn:aws:cloudwatch:us-east-1:${local.account_id}:alarm:${var.project_name}-wafv2-blocked-requests-anomaly-detection",
      "arn:aws:cloudwatch:us-east-1:${local.account_id}:alarm:${var.project_name}-wafv2-country-blocked-requests",
      "arn:aws:cloudwatch:us-east-1:${local.account_id}:alarm:${var.project_name}-wafv2-high-rate-blocked-requests",
      "arn:aws:cloudwatch:us-east-1:${local.account_id}:alarm:${var.project_name}-wafv2-sql-injection-alarm",
      "arn:aws:cloudwatch:us-east-1:${local.account_id}:alarm:${var.project_name}-wafv2-scanning-alarm",
      "arn:aws:cloudwatch:us-east-1:${local.account_id}:alarm:${var.project_name}-wafv2-anonymous-alarm",
      "arn:aws:cloudwatch:us-east-1:${local.account_id}:alarm:${var.project_name}-wafv2-bots-alarm",
      "arn:aws:cloudwatch:us-east-1:${local.account_id}:alarm:${var.project_name}-cloudfront-requests-anomaly-detection",
      "arn:aws:cloudwatch:us-east-1:${local.account_id}:alarm:${var.project_name}-cloudfront-bytes-downloaded-anomaly-detection",
      "arn:aws:cloudwatch:us-east-1:${local.account_id}:alarm:${var.project_name}-cloudfront-5xx-errors-alarm",
      "arn:aws:cloudwatch:us-east-1:${local.account_id}:alarm:${var.project_name}-cloudfront-origin-latency-alarm",
      "arn:aws:cloudwatch:us-east-1:${local.account_id}:alarm:${var.project_name}-cloudfront-staging-5xx-errors-alarm",
      "arn:aws:cloudwatch:us-east-1:${local.account_id}:alarm:${var.project_name}-cloudfront-staging-origin-latency-alarm",
      "arn:aws:cloudwatch:us-east-1:${local.account_id}:alarm:${var.project_name}-cloudfront-requests-flood-alarm",
      "arn:aws:cloudwatch:${var.region}:${local.account_id}:alarm:${var.project_name}-heartbeat-canary-2xx",
      "arn:aws:cloudwatch:${var.region}:${local.account_id}:alarm:${var.project_name}-s3-objects-anomaly-detection",
      "arn:aws:cloudwatch:${var.region}:${local.account_id}:alarm:${var.project_name}-s3-requests-anomaly-detection",
      "arn:aws:cloudwatch:${var.region}:${local.account_id}:alarm:${var.project_name}-s3-4xx-errors-anomaly-detection",
      "arn:aws:cloudwatch:${var.region}:${local.account_id}:alarm:${var.project_name}-lambda-s3-invocations-anomaly-detection",
      "arn:aws:cloudwatch:${var.region}:${local.account_id}:alarm:${var.project_name}-lambda-s3-errors-detection",
      "arn:aws:cloudwatch:${var.region}:${local.account_id}:alarm:${var.project_name}-lambda-s3-throttles-anomaly-detection",
      "arn:aws:cloudwatch:${var.region}:${local.account_id}:alarm:${var.project_name}-lambda-s3-duration-anomaly-detection",
      "arn:aws:cloudwatch:${var.region}:${local.account_id}:alarm:${var.project_name}-staging-s3-4xx-errors-anomaly-detection",

    ]
  }
  statement {
    sid    = "LogsPolicy"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogDelivery",
      "logs:DescribeResourcePolicies",
      "logs:ListTagsLogGroup",
      "logs:ListTagsForResource",
      "logs:GetLogEvents",
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy",
      "logs:PutResourcePolicy",
      "logs:DeleteLogGroup",
      "logs:DeleteLogDelivery"
    ]
    resources = [
      "arn:aws:logs:us-east-1:${local.account_id}:log-group:*",
      "arn:aws:logs:${var.region}:${local.account_id}:log-group:*"
    ]
  }

  statement {
    sid    = "CanaryPolicy"
    effect = "Allow"
    actions = [
      "synthetics:CreateCanary",
      "synthetics:GetCanary",
      "synthetics:DeleteCanary",
      "synthetics:TagResource",
    ]
    resources = [
      "arn:aws:synthetics:${var.region}:${local.account_id}:canary:${var.project_name}-hearbeat",
    ]
  }
}
