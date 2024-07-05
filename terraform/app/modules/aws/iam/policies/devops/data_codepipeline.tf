
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
      "codebuild:ListReportsForReportGroup",
      "codebuild:DescribeTestCases",
      "codebuild:GetResourcePolicy",
      "codebuild:ListFleets",
      "codebuild:ListReportGroups",
      "codebuild:DescribeCodeCoverages",
      "codebuild:ListBuildsForProject",
      "codebuild:BatchGetBuilds",
      "codebuild:ListReports",
      "codebuild:ListProjects",
      "codebuild:BatchGetReportGroups",
      "codebuild:BatchGetFleets",
      "codebuild:ListConnectedOAuthAccounts",
      "codebuild:BatchGetProjects",
      "codebuild:BatchGetReports",
      "codebuild:ListCuratedEnvironmentImages",
      "codebuild:ListSourceCredentials",
      "codebuild:ListRepositories",
      "codebuild:ListSharedProjects",
      "codebuild:GetReportGroupTrend",
      "codebuild:ListBuildBatches",
      "codebuild:ListSharedReportGroups",
      "codebuild:ListBuilds",
      "codebuild:ListBuildBatchesForProject",
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

