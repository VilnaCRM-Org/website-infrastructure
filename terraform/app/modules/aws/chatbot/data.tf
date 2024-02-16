data "aws_iam_policy_document" "chatbot_role_assume_role_policy_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    sid     = "ChatBot"
    principals {
      type        = "Service"
      identifiers = ["chatbot.amazonaws.com"]
    }
  }
}
data "aws_iam_policy_document" "kms_key_access_doc" {
  statement {
    sid    = "AllowKMSActions"
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:Decrypt"
    ]
    resources = ["${var.kms_key_arn}"]
  }
}
