data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_iam_policy_document" "general_policy_doc" {
  statement {
    sid    = "GeneralPolicyForWebsiteUser"
    effect = "Allow"
    actions = [
      "sts:GetCallerIdentity",
      "route53:ListHostedZones",
      "kms:CreateKey",
      "cloudfront:CreateOriginAccessControl",
      "acm:RequestCertificate",
      "cloudfront:CreateDistributionWithTags",
      "logs:DescribeLogGroups",
      "s3:DeleteBucketOwnershipControls"
    ]
    resources = ["*"]
  }
} 