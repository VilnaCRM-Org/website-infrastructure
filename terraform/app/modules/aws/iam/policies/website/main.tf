resource "aws_iam_policy" "sns_policy" {
  name        = "${var.policy_prefix}-sns-policy"
  policy      = data.aws_iam_policy_document.sns_policy_doc.json
  path        = "/WebsitePolicies/"
  description = "Policy to allow to use SNS resources"

  tags = var.tags
}

resource "aws_iam_policy" "s3_policy" {
  name        = "${var.policy_prefix}-s3-policy"
  policy      = data.aws_iam_policy_document.s3_policy_doc.json
  path        = "/WebsitePolicies/"
  description = "Policy to allow to use S3 resources"

  tags = var.tags
}

resource "aws_iam_policy" "dns_policy" {
  name        = "${var.policy_prefix}-dns-policy"
  policy      = data.aws_iam_policy_document.dns_policy_doc.json
  path        = "/WebsitePolicies/"
  description = "Policy to allow to use DNS related resources"

  tags = var.tags
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.policy_prefix}-lambda-policy"
  policy      = data.aws_iam_policy_document.lambda_policy_doc.json
  path        = "/WebsitePolicies/"
  description = "Policy to allow to use Lambda resources"

  tags = var.tags
}

resource "aws_iam_policy" "kms_policy" {
  name        = "${var.policy_prefix}-kms-policy"
  policy      = data.aws_iam_policy_document.kms_policy_doc.json
  path        = "/WebsitePolicies/"
  description = "Policy to allow to use KMS resources"

  tags = var.tags
}

resource "aws_iam_policy" "iam_policy" {
  name        = "${var.policy_prefix}-iam-policy"
  policy      = data.aws_iam_policy_document.iam_policy_doc.json
  path        = "/WebsitePolicies/"
  description = "Policy to allow to use IAM resources"

  tags = var.tags
}

resource "aws_iam_policy" "general_policy" {
  name        = "${var.policy_prefix}-general-policy"
  policy      = data.aws_iam_policy_document.general_policy_doc.json
  path        = "/WebsitePolicies/"
  description = "Policy to allow to use general features"

  tags = var.tags
}

resource "aws_iam_policy" "cloudfront_policy" {
  name        = "${var.policy_prefix}-cloudfront-policy"
  policy      = data.aws_iam_policy_document.cloudfront_policy_doc.json
  path        = "/WebsitePolicies/"
  description = "Policy to allow to use Cloudfront related resources"

  tags = var.tags
}