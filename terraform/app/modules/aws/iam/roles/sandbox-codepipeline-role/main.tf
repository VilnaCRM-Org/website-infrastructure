resource "aws_iam_role" "codepipeline_role" {
  name               = var.codepipeline_iam_role_name
  tags               = var.tags
  assume_role_policy = data.aws_iam_policy_document.codepipeline_role_document.json
  path               = "/"
}

resource "aws_iam_role" "terraform_role" {
  name               = "${var.project_name}-codebuild-terraform-role"
  tags               = var.tags
  assume_role_policy = data.aws_iam_policy_document.terraform_role_document.json
  path               = "/"
}