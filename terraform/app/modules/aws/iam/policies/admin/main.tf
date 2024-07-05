resource "aws_iam_policy" "iam_policy" {
  name        = "${var.policy_prefix}-iam-policy"
  policy      = data.aws_iam_policy_document.iam_policy_doc.json
  path        = "/AdminPolicies/"
  description = "Policy to allow to use IAM"

  tags = var.tags
}