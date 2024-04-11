resource "aws_iam_role" "codepipeline_role" {
  name               = var.codepipeline_iam_role_name
  tags               = var.tags
  assume_role_policy = data.aws_iam_policy_document.codepipeline_role_document.json
  path               = "/"
}
