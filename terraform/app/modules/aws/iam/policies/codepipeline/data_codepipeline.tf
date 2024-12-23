data "aws_iam_policy_document" "codepipeline_policy_doc" {
  statement {
    sid    = "CodePipelinePolicy"
    effect = "Allow"
    actions = [
      "codepipeline:CreatePipeline",
      "codepipeline:GetPipeline",
      "codepipeline:UpdatePipeline",
      "codepipeline:ListTagsForResource",
      "codepipeline:TagResource",
      "codepipeline:DeletePipeline"
    ]
    resources = [
      "arn:aws:codepipeline:${var.region}:${local.account_id}:${var.website_project_name}-pipeline",
      "arn:aws:codepipeline:${var.region}:${local.account_id}:${var.website_project_name}-pipeline/*",
      "arn:aws:codepipeline:${var.region}:${local.account_id}:${var.ci_cd_project_name}-pipeline",
      "arn:aws:codepipeline:${var.region}:${local.account_id}:${var.ci_cd_project_name}-pipeline/*",
      "arn:aws:codepipeline:${var.region}:${local.account_id}:${var.ci_cd_website_project_name}-pipeline",
      "arn:aws:codepipeline:${var.region}:${local.account_id}:${var.ci_cd_website_project_name}-pipeline/*",
      "arn:aws:codepipeline:${var.region}:${local.account_id}:sandbox-deletion",
      "arn:aws:codepipeline:${var.region}:${local.account_id}:sandbox-deletion/*",
      "arn:aws:codepipeline:${var.region}:${local.account_id}:sandbox-creation",
      "arn:aws:codepipeline:${var.region}:${local.account_id}:sandbox-creation/*"
    ]
  }
  statement {
    sid    = "CodeBuildCreatePolicy"
    effect = "Allow"
    actions = [
      "codebuild:CreateProject",
      "codebuild:BatchGetProjects",
      "codebuild:UpdateProject",
      "codebuild:DeleteProject"
    ]
    resources = [
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.website_project_name}-validate",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.website_project_name}-plan",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.website_project_name}-up",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.website_project_name}-deploy",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.website_project_name}-healthcheck",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.website_project_name}-down",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.ci_cd_project_name}-validate",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.ci_cd_project_name}-plan",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.ci_cd_project_name}-up",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.ci_cd_website_project_name}-deploy",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.ci_cd_website_project_name}-healthcheck",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.ci_cd_website_project_name}-batch-lhci-leak",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.ci_cd_website_project_name}-batch-unit-mutation-lint",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.ci_cd_website_project_name}-batch-pw-load",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.ci_cd_website_project_name}-trigger",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.ci_cd_website_project_name}-rollback",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.ci_cd_website_project_name}-release",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/sandbox-${var.environment}-healthcheck",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/sandbox-${var.environment}-up",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/sandbox-${var.environment}-delete",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/sandbox-${var.environment}-deploy",
    ]
  }
  statement {
    sid    = "CodeBuildPolicy"
    effect = "Allow"
    actions = [
      "codebuild:BatchGetProjects",
      "codebuild:DeleteProject"
    ]
    resources = [
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.website_project_name}-validate",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.website_project_name}-plan",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.website_project_name}-up",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.website_project_name}-deploy",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.website_project_name}-healthcheck",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.website_project_name}-down",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.ci_cd_project_name}-validate",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.ci_cd_project_name}-plan",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.ci_cd_project_name}-up",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.ci_cd_website_project_name}-deploy",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.ci_cd_website_project_name}-healthcheck",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.ci_cd_website_project_name}-batch-lhci-leak",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.ci_cd_website_project_name}-batch-unit-mutation-lint",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.ci_cd_website_project_name}-batch-pw",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.ci_cd_website_project_name}-trigger",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.ci_cd_website_project_name}-rollback",
      "arn:aws:codebuild:${var.region}:${local.account_id}:project/${var.ci_cd_website_project_name}-release",
    ]
  }
  statement {
    sid    = "CodeStarConnectionsPolicy"
    effect = "Allow"
    actions = [
      "codestar-connections:ListConnections",
      "codestar-connections:ListTagsForResource",
      "codestar-connections:PassConnection"
    ]
    resources = ["arn:aws:codestar-connections:${var.region}:${local.account_id}:*",
      "arn:aws:codeconnections:${var.region}:${local.account_id}:connection/*"
    ]
  }
  statement {
    sid    = "CodeStarNotificationsPolicy"
    effect = "Allow"
    actions = [
      "codestar-notifications:CreateNotificationRule",
      "codestar-notifications:DescribeNotificationRule",
      "codestar-notifications:DeleteNotificationRule"
    ]
    resources = ["arn:aws:codestar-notifications:${var.region}:${local.account_id}:notificationrule/*"]
  }
  statement {
    sid    = "CloudFormationChatBotModulePolicy"
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
    sid    = "ChatbotGeneralSlackPolicy"
    effect = "Allow"
    actions = [
      "chatbot:DescribeSlackChannelConfigurations",
      "chatbot:UpdateSlackChannelConfiguration",
      "chatbot:DeleteSlackChannelConfiguration",
      "chatbot:CreateSlackChannelConfiguration",
    ]
    #checkov:skip=CKV_AWS_356:Required by AWSCC module
    #checkov:skip=CKV_AWS_111:Required by AWSCC module
    resources = ["*"]
  }
  statement {
    sid    = "AllowSecretsManagerAccess"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:CreateSecret",
      "secretsmanager:PutSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetResourcePolicy"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:secretsmanager:${data.aws_region.current.id}:${local.account_id}:secret:github-token-*"
    ]
  }
}