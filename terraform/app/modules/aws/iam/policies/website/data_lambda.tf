data "aws_iam_policy_document" "lambda_policy_doc" {
  statement {
    sid    = "LambdaPolicy"
    effect = "Allow"
    actions = [
      "lambda:CreateFunction",
      "lambda:GetFunction",
      "lambda:GetFunctionConfiguration",
      "lambda:ListVersionsByFunction",
      "lambda:GetFunctionCodeSigningConfig",
      "lambda:UpdateFunctionConfiguration",
      "lambda:AddPermission",
      "lambda:PublishVersion",
      "lambda:DeleteVersion",
      "lambda:GetPolicy",
      "lambda:RemovePermission",
      "lambda:DeleteFunction"
    ]
    resources = [
      "arn:aws:lambda:${var.region}:${local.account_id}:function:${var.project_name}-website-infra-s3-notifications",
      "arn:aws:lambda:${var.region}:${local.account_id}:function:${var.project_name}-staging-website-infra-s3-notifications",
      "arn:aws:lambda:${var.region}:${local.account_id}:function:cwsyn-*"
    ]
  }
  statement {
    sid    = "LambdaLayerVersionPolicy"
    effect = "Allow"
    actions = [
      "lambda:AddLayerVersionPermission",
      "lambda:AddLayerVersionPermission",
      "lambda:GetLayerVersionPolicy",
      "lambda:RemoveLayerVersionPermission",
      "lambda:GetLayerVersion",
      "lambda:PublishLayerVersion",
      "lambda:DeleteLayerVersion",
    ]
    resources = [
      "arn:aws:lambda:${var.region}:${local.account_id}:layer:*",
      "arn:aws:lambda:${var.region}:122305336817:layer:*" # Runtime versions layers
    ]
  }
} 