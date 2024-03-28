data "aws_iam_policy_document" "lambda_policy_doc" {
  statement {
    sid    = "LogsPolicyForWebsiteUser"
    effect = "Allow"
    actions = [
      "lambda:CreateFunction",
      "lambda:GetFunction",
      "lambda:ListVersionsByFunction",
      "lambda:GetFunctionCodeSigningConfig",
      "lambda:AddPermission",
      "lambda:GetPolicy",
      "lambda:RemovePermission",
      "lambda:DeleteFunction"
    ]
    resources = [
      "arn:aws:lambda:${var.region}:${local.account_id}:function:${var.project_name}-lambda-func"
    ]
  }
} 