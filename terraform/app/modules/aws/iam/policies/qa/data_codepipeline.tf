
data "aws_iam_policy_document" "codepipeline_policy_doc" {
  statement {
    sid    = "CodePipelinePolicy"
    effect = "Allow"
    actions = [
      "codepipeline:ListPipelineExecutions",
      "codepipeline:ListPipelines",
      "codepipeline:GetActionType",
      "codepipeline:GetJobDetails",
      "codepipeline:GetPipeline",
      "codepipeline:GetPipelineExecution",
      "codepipeline:GetPipelineState",
      "codepipeline:GetThirdPartyJobDetails",
      "codepipeline:ListActionExecutions",
      "codepipeline:ListActionTypes",
      "codepipeline:ListTagsForResource",
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
      "codebuild:ListBuildBatches",
      "codebuild:ListBuildBatchesForProject",
      "codebuild:ListBuilds",
      "codebuild:ListBuildsForProject",
      "codebuild:ListConnectedOAuthAccounts",
      "codebuild:ListCuratedEnvironmentImages",
      "codebuild:ListFleets",
      "codebuild:ListProjects",
      "codebuild:ListReportGroups",
      "codebuild:ListReports",
      "codebuild:ListReportsForReportGroup",
      "codebuild:ListRepositories",
      "codebuild:ListSharedProjects",
      "codebuild:ListSharedReportGroups",
      "codebuild:ListSourceCredentials",
      "codebuild:BatchGetBuildBatches",
      "codebuild:BatchGetBuilds",
      "codebuild:BatchGetFleets",
      "codebuild:BatchGetProjects",
      "codebuild:BatchGetReportGroups",
      "codebuild:BatchGetReports",
      "codebuild:DescribeCodeCoverages",
      "codebuild:DescribeTestCases",
      "codebuild:GetReportGroupTrend",
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
}

