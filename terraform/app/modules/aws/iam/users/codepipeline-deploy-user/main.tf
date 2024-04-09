resource "aws_iam_user" "codepipeline_user" {
  #checkov:skip=CKV_AWS_273: SSO is not an option
  name = "codepipelineUser"
  path = "/codepipeline-users/"

  tags = var.tags
}

resource "aws_iam_group_membership" "codepipeline_group_membership" {
  name = "codepipeline-group-membership"

  users = [
    aws_iam_user.codepipeline_user.name
  ]
  #checkov:skip=CKV2_AWS_14: Will be added at the end of stack execution
  #checkov:skip=CKV2_AWS_21: Will be added at the end of stack execution
  group = var.codepipeline_user_group_name
}