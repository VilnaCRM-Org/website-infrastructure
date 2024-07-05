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
      "arn:aws:iam::${local.account_id}:role/reports-chatbot-channel-role"
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
      "arn:aws:iam::${local.account_id}:policy/${var.ci_cd_website_project_name}-iam-policy-allow-logging-for-lambda"
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