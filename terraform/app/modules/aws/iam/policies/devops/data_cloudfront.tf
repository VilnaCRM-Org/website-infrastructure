data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_iam_policy_document" "cloudfront_policy_doc" {
  statement {
    sid    = "ListCloudfrontPolicy"
    effect = "Allow"
    actions = [
      "cloudfront:ListCloudFrontOriginAccessIdentities",
      "cloudfront:ListFunctions",
      "cloudfront:ListOriginAccessControls",
      "cloudfront:ListFieldLevelEncryptionConfigs",
      "cloudfront:ListOriginRequestPolicies",
      "cloudfront:ListDistributionsByRealtimeLogConfig",
      "cloudfront:ListKeyGroups",
      "cloudfront:ListSavingsPlans",
      "cloudfront:ListRateCards",
      "cloudfront:ListContinuousDeploymentPolicies",
      "cloudfront:ListUsages",
      "cloudfront:ListResponseHeadersPolicies",
      "cloudfront:ListDistributionsByCachePolicyId",
      "cloudfront:ListDistributionsByLambdaFunction",
      "cloudfront:ListCachePolicies",
      "cloudfront:ListDistributionsByKeyGroup",
      "cloudfront:ListPublicKeys",
      "cloudfront:ListConflictingAliases",
      "cloudfront:ListRealtimeLogConfigs",
      "cloudfront:ListInvalidations",
      "cloudfront:ListFieldLevelEncryptionProfiles",
      "cloudfront:ListDistributions",
      "cloudfront:ListStreamingDistributions",
      "cloudfront:ListKeyValueStores",
      "cloudfront:ListDistributionsByWebACLId",
      "cloudfront:ListDistributionsByResponseHeadersPolicyId",
      "cloudfront:ListDistributionsByOriginRequestPolicyId"
    ]
    resources = [
      "arn:aws:cloudfront::${local.account_id}:*"
    ]
  }
  statement {
    sid    = "GetCloudfrontDistributionPolicy"
    effect = "Allow"
    actions = [
      "cloudfront:GetContinuousDeploymentPolicy",
      "cloudfront:GetFunction",
      "cloudfront:GetPublicKeyConfig",
      "cloudfront:GetMonitoringSubscription",
      "cloudfront:GetContinuousDeploymentPolicyConfig",
      "cloudfront:GetSavingsPlan",
      "cloudfront:GetDistribution",
      "cloudfront:GetResponseHeadersPolicyConfig",
      "cloudfront:GetStreamingDistribution",
      "cloudfront:DescribeKeyValueStore",
      "cloudfront:GetKeyGroup",
      "cloudfront:GetFieldLevelEncryption",
      "cloudfront:GetOriginRequestPolicy",
      "cloudfront:GetCloudFrontOriginAccessIdentity",
      "cloudfront:GetDistributionConfig",
      "cloudfront:GetKeyGroupConfig",
      "cloudfront:GetFieldLevelEncryptionProfile",
      "cloudfront:GetFieldLevelEncryptionConfig",
      "cloudfront:GetCloudFrontOriginAccessIdentityConfig",
      "cloudfront:GetCachePolicyConfig",
      "cloudfront:GetOriginAccessControlConfig",
      "cloudfront:GetStreamingDistributionConfig",
      "cloudfront:GetResponseHeadersPolicy",
      "cloudfront:GetPublicKey",
      "cloudfront:GetInvalidation",
      "cloudfront:GetOriginRequestPolicyConfig",
      "cloudfront:GetRealtimeLogConfig",
      "cloudfront:DescribeFunction",
      "cloudfront:ListTagsForResource",
      "cloudfront:GetOriginAccessControl",
      "cloudfront:GetCachePolicy",
      "cloudfront:GetFieldLevelEncryptionProfileConfig"
    ]
    resources = [
      "arn:aws:cloudfront::${local.account_id}:distribution/*"
    ]
  }

}