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
      identifiers = ["arn:aws:iam::${local.account_id}:role/ci-cd-infra-${var.environment}-codepipeline-role"]
    }
  }
  statement {
    sid     = "AllowWesiteInfraRoleAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:role/website-infra-${var.environment}-codepipeline-role"]
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
    ]
    resources = local.is_website_infra ? local.website_infra_codepipeline_policy_bucket_access : local.ci_cd_infra_codepipeline_policy_bucket_access
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
    sid    = "AllowSecretsManagerAccess"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
    "arn:${data.aws_partition.current.partition}:secretsmanager:${data.aws_region.current.id}:${local.account_id}:secret:github-token-*"]
  }
}

data "aws_iam_policy_document" "terraform_ci_cd_policy_document" {
  statement {
    sid    = "GetCallerIdentityPolicy"
    effect = "Allow"
    actions = [
      "sts:GetCallerIdentity",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CloudFrontListDistributionsPolicy"
    effect = "Allow"
    actions = [
      "cloudfront:ListDistributions",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CodeBuildProjectReadPolicy"
    effect = "Allow"
    actions = [
      "codebuild:BatchGetProjects",
    ]
    resources = [
      "arn:aws:codebuild:${data.aws_region.current.id}:${local.account_id}:project/*",
    ]
  }

  statement {
    sid    = "CloudFrontDistributionManagementPolicy"
    effect = "Allow"
    actions = [
      "cloudfront:GetDistribution",
      "cloudfront:GetDistributionConfig",
      "cloudfront:DisassociateDistributionWebACL",
      "cloudfront:UpdateDistribution",
    ]
    resources = [
      "arn:aws:cloudfront::${local.account_id}:distribution/*",
    ]
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
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:DeleteItem"
    ]
    resources = ["arn:aws:dynamodb:${var.region}:${local.account_id}:table/terraform_locks"]
  }

  statement {
    sid    = "AllowSecretsManagerAccess"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      "arn:aws:secretsmanager:${var.region}:${local.account_id}:secret:github-token-*"
    ]
  }

  statement {
    sid    = "AllowSecretsManagerListSecrets"
    effect = "Allow"
    actions = [
      "secretsmanager:ListSecrets",
    ]
    resources = [
      "*"
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
    resources = [
      "arn:aws:s3:::terraform-state-${local.account_id}-${var.region}-${var.environment}/main/${var.region}/${var.environment}/stacks/ci-cd-iam/terraform.tfstate",
      "arn:aws:s3:::terraform-state-${local.account_id}-${var.region}-${var.environment}/main/${var.region}/${var.environment}/stacks/website-iam/terraform.tfstate",
      "arn:aws:s3:::terraform-state-${local.account_id}-${var.region}-${var.environment}/main/${var.region}/${var.environment}/stacks/iam-groups/terraform.tfstate"
    ]
  }

  statement {
    sid    = "IAMUserPolicy"
    effect = "Allow"
    actions = [
      "iam:CreateUser",
      "iam:GetUser",
      "iam:TagUser"
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:user/codepipeline-users/codepipelineUser",
      "arn:aws:iam::${local.account_id}:user/website-users/websiteUser",
    ]
  }

  statement {
    sid    = "IAMGroupAttachPolicy"
    effect = "Allow"
    actions = [
      "iam:GetGroup",
      "iam:AddUserToGroup",
      "iam:AttachGroupPolicy",
      "iam:ListAttachedGroupPolicies",
      "iam:AddUserToGroup",
      "iam:DeleteGroup"
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:group/website-users",
      "arn:aws:iam::${local.account_id}:group/codepipeline-users",
      "arn:aws:iam::${local.account_id}:group/backend-users",
      "arn:aws:iam::${local.account_id}:group/devops-users",
      "arn:aws:iam::${local.account_id}:group/qa-users",
      "arn:aws:iam::${local.account_id}:group/frontend-users",
      "arn:aws:iam::${local.account_id}:group/admin-users",
    ]
  }

  statement {
    sid    = "IAMCreateGroupPolicy"
    effect = "Allow"
    actions = [
      "iam:GetGroup",
      "iam:CreateGroup",
      "iam:AttachGroupPolicy",
      "iam:ListAttachedGroupPolicies",
      "iam:AddUserToGroup",
      "iam:DeleteGroup"
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:group/codepipeline-users/codepipeline-users",
      "arn:aws:iam::${local.account_id}:group/website-users/website-users",
      "arn:aws:iam::${local.account_id}:group/backend-users/backend-users",
      "arn:aws:iam::${local.account_id}:group/devops-users/devops-users",
      "arn:aws:iam::${local.account_id}:group/qa-users/qa-users",
      "arn:aws:iam::${local.account_id}:group/frontend-users/frontend-users",
      "arn:aws:iam::${local.account_id}:group/admin-users/admin-users"
    ]
  }

  statement {
    sid    = "AllowTerraformRoleActionsPolicy"
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:TagRole",
      "iam:UpdateRole",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies"
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:role/ci-cd-infra-${var.environment}-codebuild-terraform-role",
      "arn:aws:iam::${local.account_id}:role/website-infra-${var.environment}-codebuild-terraform-role",
      "arn:aws:iam::${local.account_id}:role/ci-cd-website-${var.environment}-github-oidc-codepipeline-role",
      "arn:aws:iam::${local.account_id}:role/sandbox-${var.environment}-codebuild-terraform-role",
      "arn:aws:iam::${local.account_id}:role/sandbox-${var.environment}-codepipeline-role"
    ]
  }
}

data "aws_iam_policy_document" "terraform_iam_policy_document" {
  statement {
    sid    = "IAMUserPoliciesPolicy"
    effect = "Allow"
    actions = [
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions",
      "iam:TagPolicy",
      "iam:DeletePolicyVersion"
    ]
    resources = local.terraform_iam_managed_policy_arns
  }

  statement {
    sid    = "AllowOpenIDConnectProviderAccessPolicy"
    effect = "Allow"
    actions = [
      "iam:CreateOpenIDConnectProvider",
      "iam:UpdateOpenIDConnectProviderThumbprint",
      "iam:TagOpenIDConnectProvider",
      "iam:ListOpenIDConnectProviderTags",
      "iam:GetOpenIDConnectProvider"
    ]
    resources = ["arn:aws:iam::${local.account_id}:oidc-provider/token.actions.githubusercontent.com"]
  }

  statement {
    sid    = "AllowCICDWebsitePoliciesAccessPolicy"
    effect = "Allow"
    actions = [
      "iam:CreatePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions",
      "iam:CreatePolicyVersion",
      "iam:TagPolicy",
      "iam:DeletePolicyVersion"
    ]
    resources = local.policy_arns
  }

  statement {
    sid    = "AllowWebsiteReplicationPoliciesAccessPolicy"
    effect = "Allow"
    actions = [
      "iam:CreatePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions",
      "iam:CreatePolicyVersion",
      "iam:TagPolicy",
      "iam:DeletePolicyVersion"
    ]
    resources = local.replication_policy_arns
  }

  statement {
    sid    = "AllowCodePipelineRolePoliciesAccessPolicy"
    effect = "Allow"
    actions = [
      "iam:CreatePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions",
      "iam:CreatePolicyVersion",
      "iam:TagPolicy",
      "iam:GetRole",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:DeletePolicyVersion",
      "iam:UpdateAssumeRolePolicy"
    ]
    resources = local.codepipeline_role_policy_resources
  }

}
