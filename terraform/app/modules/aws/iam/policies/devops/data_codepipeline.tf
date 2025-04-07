
data "aws_iam_policy_document" "codepipeline_policy_doc" {
  statement {
    sid    = "CodePipelinePolicy"
    effect = "Allow"
    actions = [
      "codepipeline:ListWebhooks",
      "codepipeline:ListPipelineExecutions",
      "codepipeline:ListActionExecutions",
      "codepipeline:ListPipelines",
      "codepipeline:GetPipeline",
      "codepipeline:ListTagsForResource",
      "codepipeline:GetThirdPartyJobDetails",
      "codepipeline:GetPipelineState",
      "codepipeline:GetJobDetails",
      "codepipeline:GetActionType",
      "codepipeline:GetPipelineExecution",
      "codepipeline:ListActionTypes",
      "codepipeline:RetryStageExecution",
      "codepipeline:StartPipelineExecution",
      "codepipeline:StopPipelineExecution"
    ]
    resources = [
      "arn:aws:codepipeline:${var.region}:${local.account_id}:*"
    ]
  }
  statement {
    sid    = "CodeBuildPolicy"
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuildBatches",
      "codebuild:DescribeTestCases",
      "codebuild:GetResourcePolicy",
      "codebuild:DescribeCodeCoverages",
      "codebuild:BatchGetBuilds",
      "codebuild:BatchGetReportGroups",
      "codebuild:BatchGetFleets",
      "codebuild:BatchGetProjects",
      "codebuild:BatchGetReports",
      "codebuild:RetryBuild",
      "codebuild:RetryBuildBatch",
      "codebuild:StartBuild",
      "codebuild:StartBuildBatch",
      "codebuild:StopBuild",
      "codebuild:StopBuildBatch"
    ]
    resources = [
      "arn:aws:codebuild:${var.region}:${local.account_id}:*"
    ]
  }
  statement {
  sid    = "CodeBuildWildcardReadOnly"
  effect = "Allow"
  actions = [
    "codebuild:ListReportsForReportGroup",
    "codebuild:ListFleets",
    "codebuild:ListReportGroups",
    "codebuild:ListBuildsForProject",
    "codebuild:ListReports",
    "codebuild:ListProjects",
    "codebuild:ListConnectedOAuthAccounts",
    "codebuild:ListCuratedEnvironmentImages",
    "codebuild:ListSourceCredentials",
    "codebuild:ListRepositories",
    "codebuild:ListSharedProjects",
    "codebuild:GetReportGroupTrend",
    "codebuild:ListBuildBatches",
    "codebuild:ListSharedReportGroups",
    "codebuild:ListBuilds",
    "codebuild:ListBuildBatchesForProject",
    "codebuild:GetResourcePolicy"
  ]
  resources = ["*"]
}
  statement {
    sid    = "ChatBotPolicy"
    effect = "Allow"
    actions = [
      "chatbot:DescribeSlackWorkspaces",
      "chatbot:ListMicrosoftTeamsUserIdentities",
      "chatbot:ListMicrosoftTeamsChannelConfigurations",
      "chatbot:GetAccountPreferences",
      "chatbot:DescribeSlackChannels",
      "chatbot:ListMicrosoftTeamsConfiguredTeams",
      "chatbot:DescribeSlackChannelConfigurations",
      "chatbot:GetMicrosoftTeamsChannelConfiguration",
      "chatbot:GetMicrosoftTeamsOauthParameters",
      "chatbot:GetSlackOauthParameters",
      "chatbot:DescribeSlackUserIdentities",
      "chatbot:DescribeChimeWebhookConfigurations"
    ]
    resources = [
      "*"
    ]
    #checkov:skip=CKV_AWS_356:There is no resources specification in ChatBot
    #checkov:skip=CKV_AWS_109:There is no resources specification in ChatBot
    #checkov:skip=CKV_AWS_111:There is no resources specification in ChatBot
  }
}

