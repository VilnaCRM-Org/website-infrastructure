resource "aws_iam_policy" "codepipeline_policy" {
  name        = "${var.project_name}-codepipeline-role-policy"
  description = "Policy to allow codepipeline to execute"
  tags        = var.tags
  policy      = data.aws_iam_policy_document.codepipeline_policy_document.json
}