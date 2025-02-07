data "aws_iam_policy_document" "iam_policy_doc" {
  statement {
    sid    = "IAMCodePipelineRolePolicy"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:GetRole",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:AttachRolePolicy",
      "iam:PassRole",
      "iam:DetachRolePolicy",
      "iam:ListInstanceProfilesForRole",
      "iam:TagRole",
      "iam:DeleteRole"
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:role/${var.website_project_name}-codepipeline-role",
      "arn:aws:iam::${local.account_id}:role/${var.ci_cd_project_name}-codepipeline-role",
      "arn:aws:iam::${local.account_id}:role/${var.ci_cd_website_project_name}-codepipeline-role",
      "arn:aws:iam::${local.account_id}:role/${var.ci_cd_website_project_name}-codebuild-rollback-role",
      "arn:aws:iam::${local.account_id}:role/${var.ci_cd_website_project_name}-iam-for-lambda",
      "arn:aws:iam::${local.account_id}:role/reports-chatbot-channel-role",
      "arn:aws:iam::${local.account_id}:role/website-infrastructure-trigger-role",
      "arn:aws:iam::${local.account_id}:role/website-deploy-trigger-role",
      "arn:aws:iam::${local.account_id}:role/sandbox-deletion-trigger-role",
      "arn:aws:iam::${local.account_id}:role/sandbox-creation-trigger-role",
      "arn:aws:iam::${local.account_id}:role/ci-cd-infra-trigger-role",
      "arn:aws:iam::${local.account_id}:role/github-actions-role",
      "arn:aws:iam::${local.account_id}:role/website-${var.environment}-codepipeline-role-sandbox-deletion-${var.environment}",
      "arn:aws:iam::${local.account_id}:role/website-${var.environment}-codebuild-role-sandbox-deletion-${var.environment}",
    ]
  }
  statement {
    sid    = "IAMCodePipelinePolicyRolePolicy"
    effect = "Allow"
    actions = [
      "iam:CreatePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions",
      "iam:CreatePolicyVersion",
      "iam:TagPolicy",
      "iam:DeletePolicyVersion",
      "iam:DeletePolicy"
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:policy/${var.website_project_name}-codepipeline-policy",
      "arn:aws:iam::${local.account_id}:policy/${var.ci_cd_project_name}-codepipeline-policy",
      "arn:aws:iam::${local.account_id}:policy/${var.ci_cd_project_name}-iam-policy-allow-logging-for-cloudtrail",
      "arn:aws:iam::${local.account_id}:policy/${var.ci_cd_website_project_name}-codepipeline-policy",
      "arn:aws:iam::${local.account_id}:policy/${var.ci_cd_website_project_name}-codebuild-rollback-role-policy",
      "arn:aws:iam::${local.account_id}:policy/${var.ci_cd_website_project_name}-iam-policy-allow-sns-for-lambda",
      "arn:aws:iam::${local.account_id}:policy/${var.ci_cd_website_project_name}-iam-policy-allow-logging-for-lambda",
      "arn:aws:iam::${local.account_id}:policy/SandBoxPolicies/${var.environment}-sandbox-s3-policy",
      "arn:aws:iam::${local.account_id}:policy/SandBoxPolicies/${var.environment}-sandbox-general-policy",
      "arn:aws:iam::${local.account_id}:policy/GitHubTokenSecretsAccessPolicy",
      "arn:aws:iam::${local.account_id}:policy/website-${var.environment}-codepipeline-policy",
      "arn:aws:iam::${local.account_id}:policy/website-${var.environment}-codebuild-policy",
      "arn:aws:iam::${local.account_id}:policy/website-deploy-trigger-role-policy",
      "arn:aws:iam::${local.account_id}:policy/website-infrastructure-trigger-role-policy",
      "arn:aws:iam::${local.account_id}:policy/sandbox-${var.environment}-codepipeline-role-policy",
      "arn:aws:iam::${local.account_id}:policy/sandbox-creation-trigger-role-policy",
      "arn:aws:iam::${local.account_id}:policy/sandbox-deletion-trigger-role-policy"
    ]
  }
  statement {
    sid    = "IAMPassRolePolicy"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = ["arn:aws:iam::${local.account_id}:role/*"]
  }
  statement {
    sid    = "ChatbotIAMPolicy"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:GetRole",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:AttachRolePolicy",
      "iam:PassRole",
      "iam:DetachRolePolicy",
      "iam:ListInstanceProfilesForRole",
      "iam:TagRole",
      "iam:DeleteRole"
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:role/codepipeline-chatbot-channel-role",
      "arn:aws:iam::${local.account_id}:role/ci-cd-alerts-chatbot-channel-role",
      "arn:aws:iam::${local.account_id}:role/reports-chatbot-channel-role",
      "arn:aws:iam::${local.account_id}:role/${var.ci_cd_project_name}-iam-for-cloudtrail"
    ]
  }
} 