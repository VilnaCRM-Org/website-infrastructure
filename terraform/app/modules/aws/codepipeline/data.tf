data "aws_iam_policy_document" "codepipeline_topic_doc" {
  statement {
    sid     = "AllowSNSPublishIntoTopic"
    effect  = "Allow"
    actions = ["sns:Publish"]

    principals {
      type        = "Service"
      identifiers = ["codestar-notifications.amazonaws.com"]
    }

    resources = ["${aws_sns_topic.codepipeline_notifications.arn}"]
  }
}

data "aws_kms_key" "encryption_key" {
  key_id = var.kms_key_arn
}