resource "aws_iam_policy" "codebuild_policy" {
  name        = "${var.codebuild_iam_role_name}-policy"
  description = "Policy to allow Codebuild to execute"
  tags        = var.tags
  policy      = data.aws_iam_policy_document.codebuild_policy_document.json
}