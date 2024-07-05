resource "aws_iam_role" "codebuild_role" {
  name               = var.codebuild_iam_role_name
  tags               = var.tags
  assume_role_policy = data.aws_iam_policy_document.codebuild_role_document.json
  path               = "/"
}