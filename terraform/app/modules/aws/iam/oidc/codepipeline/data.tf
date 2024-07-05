data "aws_iam_policy_document" "codepipeline_policy_doc" {
  statement {
    sid    = "CodePipelinePolicy"
    effect = "Allow"
    actions = [
      "codepipeline:StartPipelineExecution",
    ]
    resources = [
      "${var.ci_cd_website_codepipeline_arn}"
    ]
  }
}

data "github_actions_public_key" "public_key" {
  repository = var.source_repo_name
}