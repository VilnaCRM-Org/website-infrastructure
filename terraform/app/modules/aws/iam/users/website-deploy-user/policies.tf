resource "aws_iam_policy" "terraform_policy" {
  name        = "website-deploy-user-terraform-policy"
  policy      = data.aws_iam_policy_document.terraform_policy_doc.json
  path        = "/Website-User/"
  description = "Policy to allow Website user to use Terraform State"

  tags = var.tags
}

resource "aws_iam_policy" "sns_policy" {
  name        = "website-deploy-user-sns-policy"
  policy      = data.aws_iam_policy_document.sns_policy_doc.json
  path        = "/Website-User/"
  description = "Policy to allow Website user to use SNS"

  tags = var.tags
}

resource "aws_iam_policy" "s3_policy" {
  name        = "website-deploy-user-s3-policy"
  policy      = data.aws_iam_policy_document.s3_policy_doc.json
  path        = "/Website-User/"
  description = "Policy to allow Website user to use S3"

  tags = var.tags
}

resource "aws_iam_policy" "dns_policy" {
  name        = "website-deploy-user-dns-policy"
  policy      = data.aws_iam_policy_document.dns_policy_doc.json
  path        = "/Website-User/"
  description = "Policy to allow Website user to use DNS related resources"

  tags = var.tags
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "website-deploy-user-lambda-policy"
  policy      = data.aws_iam_policy_document.lambda_policy_doc.json
  path        = "/Website-User/"
  description = "Policy to allow Website user to use Lambda"

  tags = var.tags
}

resource "aws_iam_policy" "kms_policy" {
  name        = "website-deploy-user-kms-policy"
  policy      = data.aws_iam_policy_document.kms_policy_doc.json
  path        = "/Website-User/"
  description = "Policy to allow Website user to use KMS"

  tags = var.tags
}

resource "aws_iam_policy" "iam_policy" {
  name        = "website-deploy-user-iam-policy"
  policy      = data.aws_iam_policy_document.iam_policy_doc.json
  path        = "/Website-User/"
  description = "Policy to allow Website user to use IAM"

  tags = var.tags
}

resource "aws_iam_policy" "general_policy" {
  name        = "website-deploy-user-general-policy"
  policy      = data.aws_iam_policy_document.general_policy_doc.json
  path        = "/Website-User/"
  description = "Policy to allow Website user to use general features"

  tags = var.tags
}

resource "aws_iam_policy" "cloudfront_policy" {
  name        = "website-deploy-user-cloudfront-policy"
  policy      = data.aws_iam_policy_document.cloudfront_policy_doc.json
  path        = "/Website-User/"
  description = "Policy to allow Website user to use Cloudfront related resources"

  tags = var.tags
}