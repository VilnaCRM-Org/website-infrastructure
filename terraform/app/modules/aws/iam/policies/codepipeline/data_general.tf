data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_iam_policy_document" "general_policy_doc" {
  statement {
    sid    = "GeneralPolicy"
    effect = "Allow"
    actions = [
      "sts:GetCallerIdentity",
      "kms:CreateKey",
      "codestar-notifications:DeleteTarget",
      "cloudtrail:DescribeTrails"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "TerraformStateListS3Policy"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketTagging"
    ]
    resources = ["arn:aws:s3:::terraform-state-${local.account_id}-${var.region}-${var.environment}"]
  }

  statement {
    sid    = "DynamoDBStatePolicy"
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:DescribeContinuousBackups",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:ListTagsOfResource",
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:DeleteItem"
    ]
    resources = ["arn:aws:dynamodb:${var.region}:${local.account_id}:table/terraform_locks"]
  }
  statement {
    sid    = "CloudTrailPolicy"
    effect = "Allow"
    actions = [
      "cloudtrail:GetResourcePolicy",
      "cloudtrail:GetEventSelectors",
      "cloudtrail:GetTrail",
      "cloudtrail:ListTags",
      "cloudtrail:CreateTrail",
      "cloudtrail:GetTrailStatus",
    ]
    resources = [
      "arn:aws:cloudtrail:${var.region}:${local.account_id}:*",
    ]
  }
  statement {
    sid    = "TerraformStateGetS3Policy"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject"
    ]
    resources = ["arn:aws:s3:::terraform-state-${local.account_id}-${var.region}-${var.environment}/main/${var.region}/${var.environment}/stacks/ci-cd-infrastructure/terraform.tfstate"]
  }

  statement {
    sid    = "LogsPolicy"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogDelivery",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups",
      "logs:ListTagsForResource",
      "logs:ListTagsLogGroup",
      "logs:GetLogEvents",
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy",
      "logs:PutResourcePolicy",
      "logs:DeleteLogGroup",
      "logs:DeleteLogDelivery"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:*",
    ]
  }

  statement {
    sid    = "CloudWatchDashboardPolicy"
    effect = "Allow"
    actions = [
      "cloudwatch:ListDashboards",
      "cloudwatch:GetDashboard",
      "cloudwatch:PutDashboard"
    ]
    resources = [
      "arn:aws:cloudwatch::${local.account_id}:dashboard/codebuild-dashboard"
    ]
  }
  statement {
    sid    = "CloudwatchAlarmsPolicy"
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:ListTagsForResource",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:DeleteAlarms"
    ]
    resources = [
      "arn:aws:cloudwatch:${var.region}:${local.account_id}:alarm:${var.ci_cd_project_name}-dynamodb-read-capacity-anomaly-detection",
      "arn:aws:cloudwatch:${var.region}:${local.account_id}:alarm:${var.ci_cd_project_name}-dynamodb-write-capacity-anomaly-detection",
      "arn:aws:cloudwatch:${var.region}:${local.account_id}:alarm:${var.ci_cd_project_name}-dynamodb-system-errors",
      "arn:aws:cloudwatch:${var.region}:${local.account_id}:alarm:${var.ci_cd_website_project_name}-lambda-reports-errors",
      "arn:aws:cloudwatch:${var.region}:${local.account_id}:alarm:${var.ci_cd_website_project_name}-lambda-reports-invocations-anomaly-detection",
      "arn:aws:cloudwatch:${var.region}:${local.account_id}:alarm:${var.ci_cd_website_project_name}-lambda-reports-throttles-anomaly-detection",
      "arn:aws:cloudwatch:${var.region}:${local.account_id}:alarm:${var.ci_cd_website_project_name}-lambda-reports-duration-anomaly-detection",
    ]
  }
} 