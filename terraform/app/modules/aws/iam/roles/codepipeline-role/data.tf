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
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObjectAcl",
      "s3:PutObject"
    ]
    resources = [
      "${var.s3_bucket_arn}/*",
      "${var.s3_bucket_arn}"
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
    ]
  }
}

data "aws_iam_policy_document" "terraform_iam_policy_document" {
  statement {
    sid    = "IAMUserPoliciesPolicy"
    effect = "Allow"
    actions = [
      "iam:CreatePolicy",
      "iam:CreatePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:TagPolicy",
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:policy/CodePipelinePolicies/${var.environment}-codepipeline-user-sns-policy",
      "arn:aws:iam::${local.account_id}:policy/CodePipelinePolicies/${var.environment}-codepipeline-user-kms-policy",
      "arn:aws:iam::${local.account_id}:policy/CodePipelinePolicies/${var.environment}-codepipeline-user-s3-policy",
      "arn:aws:iam::${local.account_id}:policy/CodePipelinePolicies/${var.environment}-codepipeline-user-general-policy",
      "arn:aws:iam::${local.account_id}:policy/CodePipelinePolicies/${var.environment}-codepipeline-user-iam-policy",
      "arn:aws:iam::${local.account_id}:policy/CodePipelinePolicies/${var.environment}-codepipeline-user-codepipeline-policy",
      "arn:aws:iam::${local.account_id}:policy/WebsitePolicies/${var.environment}-website-user-dns-policy",
      "arn:aws:iam::${local.account_id}:policy/WebsitePolicies/${var.environment}-website-user-iam-policy",
      "arn:aws:iam::${local.account_id}:policy/WebsitePolicies/${var.environment}-website-user-general-policy",
      "arn:aws:iam::${local.account_id}:policy/WebsitePolicies/${var.environment}-website-user-cloudfront-policy",
      "arn:aws:iam::${local.account_id}:policy/WebsitePolicies/${var.environment}-website-user-s3-policy",
      "arn:aws:iam::${local.account_id}:policy/WebsitePolicies/${var.environment}-website-user-sns-policy",
      "arn:aws:iam::${local.account_id}:policy/WebsitePolicies/${var.environment}-website-user-lambda-policy",
      "arn:aws:iam::${local.account_id}:policy/WebsitePolicies/${var.environment}-website-user-kms-policy",
      "arn:aws:iam::${local.account_id}:policy/DevOpsPolicies/${var.environment}-devops-group-cloudfront-policy",
      "arn:aws:iam::${local.account_id}:policy/DevOpsPolicies/${var.environment}-devops-group-cloudwatch-policy",
      "arn:aws:iam::${local.account_id}:policy/DevOpsPolicies/${var.environment}-devops-group-codepipeline-policy",
      "arn:aws:iam::${local.account_id}:policy/DevOpsPolicies/${var.environment}-devops-group-iam-policy",
      "arn:aws:iam::${local.account_id}:policy/DevOpsPolicies/${var.environment}-devops-group-kms-policy",
      "arn:aws:iam::${local.account_id}:policy/DevOpsPolicies/${var.environment}-devops-group-lambda-policy",
      "arn:aws:iam::${local.account_id}:policy/DevOpsPolicies/${var.environment}-devops-group-s3-policy",
      "arn:aws:iam::${local.account_id}:policy/QAPolicies/${var.environment}-qa-group-cloudfront-policy",
      "arn:aws:iam::${local.account_id}:policy/QAPolicies/${var.environment}-qa-group-cloudwatch-policy",
      "arn:aws:iam::${local.account_id}:policy/QAPolicies/${var.environment}-qa-group-codepipeline-policy",
      "arn:aws:iam::${local.account_id}:policy/QAPolicies/${var.environment}-qa-group-s3-policy",
      "arn:aws:iam::${local.account_id}:policy/FrontendPolicies/${var.environment}-frontend-group-cloudfront-policy",
      "arn:aws:iam::${local.account_id}:policy/FrontendPolicies/${var.environment}-frontend-group-cloudwatch-policy",
      "arn:aws:iam::${local.account_id}:policy/FrontendPolicies/${var.environment}-frontend-group-codepipeline-policy",
      "arn:aws:iam::${local.account_id}:policy/FrontendPolicies/${var.environment}-frontend-group-s3-policy",
      "arn:aws:iam::${local.account_id}:policy/BackendPolicies/${var.environment}-backend-group-cloudfront-policy",
      "arn:aws:iam::${local.account_id}:policy/BackendPolicies/${var.environment}-backend-group-cloudwatch-policy",
      "arn:aws:iam::${local.account_id}:policy/BackendPolicies/${var.environment}-backend-group-s3-policy",
      "arn:aws:iam::${local.account_id}:policy/AdminPolicies/${var.environment}-admin-group-iam-policy",
    ]
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
    ]
    resources = local.policy_arns
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

    ]

    resources = [
      "arn:aws:iam::${local.account_id}:policy/website-infra-${var.environment}-codepipeline-role-policy",
      "arn:aws:iam::${local.account_id}:policy/ci-cd-infra-${var.environment}-codepipeline-role-policy",
      "arn:aws:iam::${local.account_id}:policy/website-deploy-${var.environment}-codepipeline-role-policy",
      "arn:aws:iam::${local.account_id}:policy/ci-cd-infra-${var.environment}-terraform-role-ci-cd-policy",
      "arn:aws:iam::${local.account_id}:policy/website-infra-${var.environment}-terraform-role-ci-cd-policy",
      "arn:aws:iam::${local.account_id}:policy/ci-cd-infra-${var.environment}-terraform-role-iam-policy",
      "arn:aws:iam::${local.account_id}:policy/website-infra-${var.environment}-terraform-role-iam-policy",
    ]
  }

}