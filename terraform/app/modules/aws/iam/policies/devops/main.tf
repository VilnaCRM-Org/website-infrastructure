resource "aws_iam_policy" "s3_policy" {
  name        = "${var.policy_prefix}-s3-policy"
  policy      = data.aws_iam_policy_document.s3_policy_doc.json
  path        = "/DevOpsPolicies/"
  description = "Policy to allow to view S3 resources"

  tags = var.tags
}

resource "aws_iam_policy" "cloudwatch_policy" {
  name        = "${var.policy_prefix}-cloudwatch-policy"
  policy      = data.aws_iam_policy_document.cloudwatch_policy_doc.json
  path        = "/DevOpsPolicies/"
  description = "Policy to allow to use AWS logging tools"

  tags = var.tags
}

resource "aws_iam_policy" "cloudfront_policy" {
  name        = "${var.policy_prefix}-cloudfront-policy"
  policy      = data.aws_iam_policy_document.cloudfront_policy_doc.json
  path        = "/DevOpsPolicies/"
  description = "Policy to allow to view CloudFront resources"

  tags = var.tags
}

resource "aws_iam_policy" "iam_policy" {
  name        = "${var.policy_prefix}-iam-policy"
  policy      = data.aws_iam_policy_document.iam_policy_doc.json
  path        = "/DevOpsPolicies/"
  description = "Policy to allow to use AWS logging tools"

  tags = var.tags
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.policy_prefix}-lambda-policy"
  policy      = data.aws_iam_policy_document.lambda_policy_doc.json
  path        = "/DevOpsPolicies/"
  description = "Policy to allow to view Lambda resources"

  tags = var.tags
}

resource "aws_iam_policy" "codepipeline_policy" {
  name        = "${var.policy_prefix}-codepipeline-policy"
  policy      = data.aws_iam_policy_document.codepipeline_policy_doc.json
  path        = "/DevOpsPolicies/"
  description = "Policy to allow to view CodePipeline resources"

  tags = var.tags
}

resource "aws_iam_policy" "kms_policy" {
  name        = "${var.policy_prefix}-kms-policy"
  policy      = data.aws_iam_policy_document.kms_policy_doc.json
  path        = "/DevOpsPolicies/"
  description = "Policy providing read-only access to KMS resources"

  tags = var.tags
}

resource "aws_iam_policy" "billing_readonly_policy" {
  name        = "${var.policy_prefix}-billing-readonly-policy"
  policy      = data.aws_iam_policy_document.billing_readonly_policy_doc.json
  path        = "/DevOpsPolicies/"
  description = "Allows read-only access to AWS Billing"

  tags = var.tags
}