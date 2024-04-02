data "aws_iam_policy_document" "iam_policy_doc" {
  statement {
    sid    = "IAMWebsiteRolePolicy"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:GetRole",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:PassRole",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:ListInstanceProfilesForRole",
      "iam:TagRole",
      "iam:DeleteRole"
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:role/${var.project_name}-iam-for-lambda",
      "arn:aws:iam::${local.account_id}:role/${var.domain_name}-iam-role-replication"
    ]
  }
  statement {
    sid    = "IAMWebsitePolicyRolePolicy"
    effect = "Allow"
    actions = [
      "iam:CreatePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions",
      "iam:TagPolicy",
      "iam:DeletePolicy"
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:policy/${var.project_name}-iam-policy-allow-sns-for-lambda",
      "arn:aws:iam::${local.account_id}:policy/${var.domain_name}-iam-role-policy-replication"
    ]
  }
  statement {
    sid    = "IAMPassRolePolicy"
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
    resources = ["arn:aws:iam::${local.account_id}:role/*"]
  }
} 