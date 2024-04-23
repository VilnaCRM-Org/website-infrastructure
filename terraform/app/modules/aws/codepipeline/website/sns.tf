resource "aws_sns_topic" "codepipeline_notifications" {
  name = "${var.project_name}-notifications"

  kms_master_key_id = aws_kms_key.codepipeline_sns_encryption_key.id

  tags = var.tags

  depends_on = [aws_codepipeline.terraform_pipeline, aws_kms_key.codepipeline_sns_encryption_key]
}

resource "aws_sns_topic_policy" "codepipeline_notifications" {
  arn    = aws_sns_topic.codepipeline_notifications.arn
  policy = data.aws_iam_policy_document.codepipeline_topic_doc.json

  depends_on = [aws_sns_topic.codepipeline_notifications]
}

resource "aws_sns_topic" "lhci_reports_notifications" {
  name = "${var.project_name}-lhci-reports-notifications"

  kms_master_key_id = aws_kms_key.lhci_reports_sns_encryption_key.id

  tags = var.tags

  depends_on = [aws_codepipeline.terraform_pipeline, aws_kms_key.lhci_reports_sns_encryption_key]
}

resource "aws_sns_topic_policy" "lhci_reports_notifications" {
  arn    = aws_sns_topic.lhci_reports_notifications.arn
  policy = data.aws_iam_policy_document.lhci_reports_sns_topic_doc.json

  depends_on = [aws_sns_topic.lhci_reports_notifications]
}