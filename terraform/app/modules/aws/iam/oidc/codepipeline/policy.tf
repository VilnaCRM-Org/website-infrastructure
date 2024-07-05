resource "aws_iam_policy" "codepipeline_policy" {
  name        = "${var.project_name}-oidc-codepipeline-policy"
  policy      = data.aws_iam_policy_document.codepipeline_policy_doc.json
  path        = "/CodePipelinePolicies/"
  description = "Policy to allow to start CodePipeline execution"

  tags = var.tags
}
