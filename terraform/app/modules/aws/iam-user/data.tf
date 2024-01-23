data "aws_iam_policy_document" "codepipeline_execute_policy_doc" {
  statement {
    effect    = "Allow"
    actions   = ["codepipeline:StartPipelineExecution"]
    resources = ["${var.codepipeline_terraform_arn}"]
  }
}