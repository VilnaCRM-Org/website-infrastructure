data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_iam_policy_document" "codepipeline_role_document" {
  statement {
    sid     = "AllowAssumeRoleByCodePipeline"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }

  statement {
    sid     = "AllowAssumeRoleByCodeBuild"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codepipeline_policy_document" {
  statement {
    sid    = "AllowS3Actions"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObjectAcl",
      "s3:PutObject"
    ]
    resources = [
      "${var.s3_bucket_arn}/*",
      "${var.s3_bucket_arn}",
      "arn:aws:s3:::${var.website_bucket_name}",
      "arn:aws:s3:::${var.website_bucket_name}/*",
      "arn:aws:s3:::staging.${var.website_bucket_name}",
      "arn:aws:s3:::staging.${var.website_bucket_name}/*",
      "${var.lhci_reports_bucket_arn}",
      "${var.lhci_reports_bucket_arn}/*",
      "${var.test_reports_bucket_bucket_arn}",
      "${var.test_reports_bucket_bucket_arn}/*"
    ]
  }

  statement {
    sid    = "AllowKMSActions"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey*",
      "kms:Decrypt"
    ]
    resources = ["${var.kms_key_arn}"]
  }

  statement {
    sid    = "AllowCodeBuildActions"
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:StartBuildBatch",
      "codebuild:BatchGetBuildBatches",
      "codebuild:StopBuild",
      "codebuild:RetryBuild",
      "codebuild:BatchGetProjects",
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
    ]
    resources = [
      "arn:aws:codebuild:${data.aws_region.current.id}:${local.account_id}:project/${var.project_name}*",
      "arn:aws:codebuild:${data.aws_region.current.id}:${local.account_id}:report-group/${var.project_name}*"
    ]
  }

  statement {
    sid    = "AllowUseOfCodeStarConnection"
    effect = "Allow"
    actions = [
      "codestar-connections:UseConnection"
    ]
    resources = ["${var.codestar_connection_arn}"]

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "codestar-connections:FullRepositoryId"
      values   = ["${var.source_repo_owner}/${var.source_repo_name}"]
    }
  }

  statement {
    sid    = "AllowLogsActions"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.id}:${local.account_id}:log-group:*"]
  }

  statement {
    sid    = "AllowInvokeLambda"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = ["arn:aws:lambda:${data.aws_region.current.id}:${local.account_id}:function:ci-cd-website-${var.environment}-reports-notification"]
  }
  statement {
    sid    = "AllowChangeAlarmState"
    effect = "Allow"
    actions = [
      "cloudwatch:EnableAlarmActions",
      "cloudwatch:DisableAlarmActions"
    ]
    resources = ["arn:aws:cloudwatch:${var.region}:${local.account_id}:alarm:website-${var.region}-s3-objects-anomaly-detection"]
  }
  statement {
    sid    = "CloudfrontDistributionListPolicy"
    effect = "Allow"
    actions = [
      "cloudfront:ListDistributions",
      "cloudfront:ListContinuousDeploymentPolicies"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid    = "CloudfrontDistributionPolicy"
    effect = "Allow"
    actions = [
      "cloudfront:CreateDistribution",
      "cloudfront:CreateDistributionWithTags",
      "cloudfront:GetDistribution",
      "cloudfront:ListDistributions",
      "cloudfront:GetDistributionConfig",
      "cloudfront:ListTagsForResource",
      "cloudfront:UpdateDistribution",
      "cloudfront:TagResource",
    ]
    resources = [
      "arn:aws:cloudfront::${local.account_id}:distribution/*"
    ]
  }
  statement {
    sid    = "CloudfrontContinuousDeploymentPolicy"
    effect = "Allow"
    actions = [
      "cloudfront:CreateContinuousDeploymentPolicy",
      "cloudfront:GetContinuousDeploymentPolicy",
      "cloudfront:UpdateContinuousDeploymentPolicy"
    ]
    resources = [
      "arn:aws:cloudfront::${local.account_id}:continuous-deployment-policy/*"
    ]
  }
}