data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_iam_policy_document" "cloudfront_policy_doc" {
  statement {
    sid    = "ListCloudfrontPolicy"
    effect = "Allow"
    actions = [
      "cloudfront:ListDistributions",
      "cloudfront:ListDistributionsByCachePolicyId",
      "cloudfront:ListDistributionsByKeyGroup",
      "cloudfront:ListDistributionsByLambdaFunction",
      "cloudfront:ListDistributionsByOriginRequestPolicyId",
      "cloudfront:ListDistributionsByRealtimeLogConfig",
      "cloudfront:ListDistributionsByResponseHeadersPolicyId",
      "cloudfront:ListDistributionsByWebACLId",
      "cloudfront:ListFunctions",
      "cloudfront:ListInvalidations",
      "cloudfront:ListOriginAccessControls",
      "cloudfront:ListOriginRequestPolicies",
      "cloudfront:ListRateCards",
      "cloudfront:ListRealtimeLogConfigs",
      "cloudfront:ListResponseHeadersPolicies",
      "cloudfront:ListStreamingDistributions",
      "cloudfront:ListUsages",
    ]
    resources = [
      "arn:aws:cloudfront::${local.account_id}:*"
    ]
  }
  statement {
    sid    = "GetCloudfrontDistributionPolicy"
    effect = "Allow"
    actions = [
      "cloudfront:GetDistribution",
      "cloudfront:GetDistributionConfig",
      "cloudfront:GetInvalidation",
      "cloudfront:GetOriginAccessControl",
      "cloudfront:GetOriginAccessControlConfig",
      "cloudfront:GetOriginRequestPolicy",
      "cloudfront:GetOriginRequestPolicyConfig",
      "cloudfront:GetRealtimeLogConfig",
      "cloudfront:GetResponseHeadersPolicy",
      "cloudfront:GetResponseHeadersPolicyConfig",
      "cloudfront:GetStreamingDistribution",
      "cloudfront:GetStreamingDistributionConfig"
    ]
    resources = [
      "arn:aws:cloudfront::${local.account_id}:distribution/*"
    ]
  }

}