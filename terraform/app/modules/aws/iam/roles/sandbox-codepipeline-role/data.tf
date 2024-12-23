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

data "aws_iam_policy_document" "terraform_role_document" {
  statement {
    sid     = "AllowCICDInfraRoleAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${local.account_id}:role/sandbox-${var.environment}${var.codepipeline_role_name_suffix}"]
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
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = ["${var.s3_bucket_arn}/*",
      "${var.s3_bucket_arn}",
      "arn:aws:s3:::${var.project_name}-${var.BRANCH_NAME}",
    "arn:aws:s3:::${var.project_name}-${var.BRANCH_NAME}/*"]
  }

  statement {
    sid    = "AllowCodepipelineGetState"
    effect = "Allow"
    actions = [
      "codepipeline:GetPipelineState",
    ]
    resources = ["arn:${data.aws_partition.current.partition}:codepipeline:${var.region}:${local.account_id}:sandbox-creation"]
  }

  statement {
    sid    = "AllowCodeBuildActions"
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:BatchGetProjects",
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:codebuild:${data.aws_region.current.id}:${local.account_id}:project/${var.project_name}*",
      "arn:${data.aws_partition.current.partition}:codebuild:${data.aws_region.current.id}:${local.account_id}:report-group/${var.project_name}*"
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
    sid    = "S3PolicyArtifactBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObjectAcl",
      "s3:PutObject"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${var.project_name}-*",
    ]
  }

  statement {
    sid    = "AllowSecretsManagerAccess"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:CreateSecret",
      "secretsmanager:PutSecretValue"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:secretsmanager:${data.aws_region.current.id}:${local.account_id}:secret:${var.github_token_secret_name}*"
    ]
  }
}