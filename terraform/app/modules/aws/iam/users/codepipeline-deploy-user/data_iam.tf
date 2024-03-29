data "aws_iam_policy_document" "iam_policy_doc" {
  statement {
    sid    = "IAMCodePipelineRolePolicyForCodePipelineUser"
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
    resources = ["arn:aws:iam::${local.account_id}:role/${var.project_name}-codepipeline-role"]
  }
  statement {
    sid    = "IAMCodePipelinePolicyRolePolicyForCodePipelineUser"
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
    resources = ["arn:aws:iam::${local.account_id}:policy/${var.project_name}-codepipeline-policy"]
  }
  statement {
    sid    = "IAMPassRolePolicyForCodePipelineUser"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = ["arn:aws:iam::${local.account_id}:role/*"]
  }
    statement {
    sid = "ChatbotIAMPolicyForCodepipelineUser"
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
    resources = ["arn:aws:iam::${local.account_id}:role/codepipeline-chatbot-channel-role"]
  }
} 