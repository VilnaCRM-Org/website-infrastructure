resource "aws_iam_policy" "terraform_policy" {
  name        = "codepipeline-deploy-user-terraform-policy"
  policy      = data.aws_iam_policy_document.terraform_policy_doc.json
  path        = "/CodePipeline-User/"
  description = "Policy to allow CodePipeline user to use Terraform State"

  tags = var.tags
}

resource "aws_iam_policy" "sns_policy" {
  name        = "codepipeline-deploy-user-sns-policy"
  policy      = data.aws_iam_policy_document.sns_policy_doc.json
  path        = "/CodePipeline-User/"
  description = "Policy to allow CodePipeline user to use SNS"

  tags = var.tags
}

resource "aws_iam_policy" "s3_policy" {
  name        = "codepipeline-deploy-user-s3-policy"
  policy      = data.aws_iam_policy_document.s3_policy_doc.json
  path        = "/CodePipeline-User/"
  description = "Policy to allow CodePipeline user to use S3"

  tags = var.tags
}

resource "aws_iam_policy" "kms_policy" {
  name        = "codepipeline-deploy-user-kms-policy"
  policy      = data.aws_iam_policy_document.kms_policy_doc.json
  path        = "/CodePipeline-User/"
  description = "Policy to allow CodePipeline user to use KMS"

  tags = var.tags
}

resource "aws_iam_policy" "iam_policy" {
  name        = "codepipeline-deploy-user-iam-policy"
  policy      = data.aws_iam_policy_document.iam_policy_doc.json
  path        = "/CodePipeline-User/"
  description = "Policy to allow CodePipeline user to use IAM"

  tags = var.tags
}

resource "aws_iam_policy" "general_policy" {
  name        = "codepipeline-deploy-user-general-policy"
  policy      = data.aws_iam_policy_document.general_policy_doc.json
  path        = "/CodePipeline-User/"
  description = "Policy to allow CodePipeline user to use general features"

  tags = var.tags
}

resource "aws_iam_policy" "codepipeline_policy" {
  name        = "codepipeline-deploy-user-codepipeline-policy"
  policy      = data.aws_iam_policy_document.codepipeline_policy_doc.json
  path        = "/CodePipeline-User/"
  description = "Policy to allow CodePipeline user to use CodePipeline related resources"

  tags = var.tags
}
