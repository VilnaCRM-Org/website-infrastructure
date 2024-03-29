data "aws_iam_policy_document" "codepipeline_policy_doc" {
  statement {
    sid    = "CodePipelinePolicyForCodePipelineUser"
    effect = "Allow"
    actions = [
      "codepipeline:CreatePipeline",
      "codepipeline:GetPipeline",
      "codepipeline:ListTagsForResource",
      "codepipeline:TagResource",
      "codepipeline:DeletePipeline"
    ]
    resources = [
      "arn:aws:codepipeline:${var.region}:${local.account_id}:${var.project_name}-pipeline",
      "arn:aws:codepipeline:${var.region}:${local.account_id}:${var.project_name}-pipeline/*"
    ]
  }
  statement {
    sid    = "CodeBuildCreatePolicyForCodePipelineUser"
    effect = "Allow"
    actions = [
      "codebuild:CreateProject",
      "codebuild:BatchGetProjects",
      "codebuild:UpdateProject",
      "codebuild:DeleteProject"
    ]
    resources = [
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.project_name}-validate",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.project_name}-plan",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.project_name}-up",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.project_name}-deploy",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.project_name}-healthcheck",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.project_name}-down"
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
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.project_name}-down",
    ]
  }
  statement {
    sid    = "CodeStarConnectionsPolicyForCodePipelineUser"
    effect = "Allow"
    actions = [
      "codestar-connections:ListConnections",
      "codestar-connections:ListTagsForResource",
      "codestar-connections:PassConnection"
    ]
    resources = ["arn:aws:codestar-connections:${var.region}:${local.account_id}:*"]
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
  statement {
    sid    = "ChatformationForChatBotPolicyForCodepipelineUser"
    effect = "Allow"
    actions = [
      "cloudformation:CreateResource",
      "cloudformation:GetResource",
      "cloudformation:ListTagsForResource",
      "cloudformation:TagResource",
      "cloudformation:GetResourceRequestStatus",
      "cloudformation:DeleteResource"
    ]
    resources = ["arn:aws:cloudformation:${var.region}:${local.account_id}:resource/*"]
  }
  statement {
    sid    = "ChatbotGeneralSlackPolicyForCodepipelineUser"
    effect = "Allow"
    actions = [
      "chatbot:DescribeSlackChannelConfigurations",
      "chatbot:UpdateSlackChannelConfiguration",
      "chatbot:DeleteSlackChannelConfiguration",
      "chatbot:CreateSlackChannelConfiguration",
    ]
    #checkov:skip=CKV_AWS_356:Required by AWSCC module
    resources = ["*"]
  }
}