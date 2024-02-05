data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

# To be used only in case of an Existing Repository
data "aws_iam_role" "existing_codepipeline_role" {
  count = var.create_new_role ? 0 : 1
  name  = var.codepipeline_iam_role_name
}

data "aws_s3_bucket" "aws_s3_bucket_backend" {
  bucket = "terraform-state-${data.aws_caller_identity.current.account_id}-${var.region}-${var.environment}"
}

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
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject"  
    ]
    resources = [
      "${var.s3_bucket_arn}/*", 
      "${var.s3_bucket_arn}", 
      "${data.aws_s3_bucket.aws_s3_bucket_backend.arn}",
      "${data.aws_s3_bucket.aws_s3_bucket_backend.arn}/*"
    ]
  }
  statement {
      
    sid    = "AllowDynamoDB"
    effect = "Allow"
        actions = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:BatchGetItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        resources = ["arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/terraform_locks"]
      
  }

  statement {
    sid    = "AllowKMSActions"
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:ReEncrypt*",
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
      "codebuild:BatchGetProjects",
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
    ]
    resources = [
      "arn:aws:codebuild:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:project/${var.project_name}*",
      "arn:aws:codebuild:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:report-group/${var.project_name}*"
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
    resources = ["arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:*"]
  }
}