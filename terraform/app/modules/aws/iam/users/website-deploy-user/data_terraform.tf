data "aws_iam_policy_document" "terraform_policy_doc" {
  statement {
    sid    = "TerraformStateListS3PolicyForWebsiteUser"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketTagging"
    ]
    resources = ["arn:aws:s3:::terraform-state-${local.account_id}-${var.region}-${var.environment}"]
  }
  statement {
    sid    = "DynamoDBStatePolicyForWebsiteUser"
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
    sid    = "TerraformStateGetS3PolicyForWebsiteUser"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject"
    ]
    resources = ["arn:aws:s3:::terraform-state-${local.account_id}-${var.region}-${var.environment}/main/${var.region}/${var.environment}/stacks/website/terraform.tfstate"]
  }
} 