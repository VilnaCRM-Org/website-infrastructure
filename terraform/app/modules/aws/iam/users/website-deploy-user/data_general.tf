data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_iam_policy_document" "general_policy_doc" {
  statement {
    sid    = "GeneralPolicy"
    effect = "Allow"
    actions = [
      "sts:GetCallerIdentity",
      "route53:ListHostedZones",
      "kms:CreateKey",
      "cloudfront:CreateOriginAccessControl",
      "acm:RequestCertificate",
      "iam:CreateServiceLinkedRole",
      "logs:DescribeLogGroups",
      "logs:CreateLogDelivery",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
    ]
    #checkov:skip=CKV_AWS_356:Required by AWSCC module
    #checkov:skip=CKV_AWS_111:Required by AWSCC module
    resources = ["*"]
  }
} 