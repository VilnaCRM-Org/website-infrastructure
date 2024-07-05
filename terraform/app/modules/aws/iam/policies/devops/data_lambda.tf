data "aws_iam_policy_document" "lambda_policy_doc" {
  statement {
    sid    = "LogsPolicy"
    effect = "Allow"
    actions = [
      "lambda:ListVersionsByFunction",
      "lambda:GetLayerVersion",
      "lambda:GetAccountSettings",
      "lambda:GetFunctionConfiguration",
      "lambda:GetLayerVersionPolicy",
      "lambda:ListProvisionedConcurrencyConfigs",
      "lambda:GetProvisionedConcurrencyConfig",
      "lambda:ListTags",
      "lambda:GetRuntimeManagementConfig",
      "lambda:ListLayerVersions",
      "lambda:ListLayers",
      "lambda:ListCodeSigningConfigs",
      "lambda:GetAlias",
      "lambda:ListFunctions",
      "lambda:GetEventSourceMapping",
      "lambda:GetFunction",
      "lambda:ListAliases",
      "lambda:GetFunctionUrlConfig",
      "lambda:ListFunctionUrlConfigs",
      "lambda:GetFunctionCodeSigningConfig",
      "lambda:ListFunctionEventInvokeConfigs",
      "lambda:ListFunctionsByCodeSigningConfig",
      "lambda:GetFunctionConcurrency",
      "lambda:GetFunctionEventInvokeConfig",
      "lambda:ListEventSourceMappings",
      "lambda:GetCodeSigningConfig",
      "lambda:GetPolicy"
    ]
    resources = [
      "arn:aws:lambda:${var.region}:${local.account_id}:*",
      "arn:aws:lambda:us-east-1:${local.account_id}:*"
    ]
  }
} 