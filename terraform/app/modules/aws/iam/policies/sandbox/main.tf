resource "aws_iam_policy" "s3_policy" {
  name        = "${var.policy_prefix}-s3-policy"
  policy      = data.aws_iam_policy_document.s3_policy_doc.json
  path        = "/SandBoxPolicies/"
  description = "Policy to allow to use S3 resources"

  tags = var.tags
}

resource "aws_iam_policy" "general_policy" {
  name        = "${var.policy_prefix}-general-policy"
  policy      = data.aws_iam_policy_document.general_policy_doc.json
  path        = "/SandBoxPolicies/"
  description = "Policy to allow to use general features"

  tags = var.tags
}
