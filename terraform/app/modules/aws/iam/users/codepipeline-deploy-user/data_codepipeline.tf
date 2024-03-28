data "aws_iam_policy_document" "codepipeline_policy_doc" {
  statement {
    sid    = "CodePipelinePolicyForCodePipelineUser"
    effect = "Allow"
    actions = [
      "codepipeline:CreatePipeline",
      "codepipeline:GetPipeline",
      "codepipeline:ListTagsForResource",
      "codepipeline:DeletePipeline"
    ]
    resources = ["arn:aws:codepipeline:${var.region}:${local.account_id}:${var.project_name}-pipeline"]
  }
  statement {
    sid    = "CodeBuildCreatePolicyForCodePipelineUser"
    effect = "Allow"
    actions = [
      "codebuild:CreateProject"
    ]
    resources = [
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.project_name}-validate",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.project_name}-plan",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.project_name}-up",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.project_name}-deploy",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.project_name}-healthcheck",
    ]
  }
  statement {
    sid    = "CodeBuildPolicyForCodePipelineUser"
    effect = "Allow"
    actions = [
      "codebuild:BatchGetProjects",
      "codebuild:DeleteProject"
    ]
    resources = [
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.project_name}-validate",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.project_name}-plan",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.project_name}-up",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.project_name}-deploy",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.project_name}-healthcheck",
    ]
  }
  statement {
    sid    = "CodeStarConnectionsPolicyForCodePipelineUser"
    effect = "Allow"
    actions = [
      "codestar-connections:ListConnections",
      "codestar-connections:ListTagsForResource"
    ]
    resources = ["arn:aws:codestar-connections:${var.region}:${local.account_id}:connection/*"]
  }
  statement {
    sid    = "CodeStarNotificationsPolicyForCodePipelineUser"
    effect = "Allow"
    actions = [
      "codestar-notifications:CreateNotificationRule",
      "codestar-notifications:DescribeNotificationRule",
      "codestar-notifications:DeleteNotificationRule"
    ]
    resources = ["arn:aws:codestar-notifications:${var.region}:${local.account_id}:notificationrule/*"]
  }
} 