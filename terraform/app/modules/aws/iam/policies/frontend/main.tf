resource "aws_iam_policy" "s3_policy" {
  name        = "${var.policy_prefix}-s3-policy"
  policy      = data.aws_iam_policy_document.s3_policy_doc.json
  path        = "/FrontendPolicies/"
  description = "Policy to allow to view S3"

  tags = var.tags
}

resource "aws_iam_policy" "cloudwatch_policy" {
  name        = "${var.policy_prefix}-cloudwatch-policy"
  policy      = data.aws_iam_policy_document.cloudwatch_policy_doc.json
  path        = "/FrontendPolicies/"
  description = "Policy to allow to use AWS logging tools"

  tags = var.tags
}

resource "aws_iam_policy" "cloudfront_policy" {
  name        = "${var.policy_prefix}-cloudfront-policy"
  policy      = data.aws_iam_policy_document.cloudfront_policy_doc.json
  path        = "/FrontendPolicies/"
  description = "Policy to allow to view CloudFront"

  tags = var.tags
}

resource "aws_iam_policy" "codepipeline_policy" {
  name        = "${var.policy_prefix}-codepipeline-policy"
  policy      = data.aws_iam_policy_document.codepipeline_policy_doc.json
  path        = "/FrontendPolicies/"
  description = "Policy to allow to access CodePipeline and CodeBuild"

  tags = var.tags
}