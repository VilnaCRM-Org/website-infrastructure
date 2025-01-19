resource "aws_iam_role" "codepipeline_role" {
  name               = var.codepipeline_iam_role_name
  tags               = var.tags
  assume_role_policy = data.aws_iam_policy_document.codepipeline_role_document.json
  path               = "/"
}

variable "terraform_role_name_suffix" {
  description = "The suffix for the Terraform role name"
  type        = string
  default     = "-codebuild-terraform-role"
}

resource "aws_iam_role" "terraform_role" {
  name               = "${var.project_name}${var.terraform_role_name_suffix}"
  tags               = var.tags
  assume_role_policy = data.aws_iam_policy_document.terraform_role_document.json
  path               = "/"
}