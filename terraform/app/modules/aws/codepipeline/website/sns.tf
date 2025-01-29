resource "aws_sns_topic" "codepipeline_notifications" {
  #checkov:skip=CKV_AWS_26: KMS encryption is not needed
  name = "${var.project_name}-notifications"

  tags = var.tags

  depends_on = [aws_codepipeline.terraform_pipeline]
}

resource "aws_sns_topic_policy" "codepipeline_notifications" {
  arn    = aws_sns_topic.codepipeline_notifications.arn
  policy = data.aws_iam_policy_document.codepipeline_topic_doc.json

  depends_on = [aws_sns_topic.codepipeline_notifications]
}

resource "aws_sns_topic" "reports_notifications" {
  #checkov:skip=CKV_AWS_26: KMS encryption is not needed
  name = "${var.project_name}-reports-notifications"

  tags = var.tags

  depends_on = [aws_codepipeline.terraform_pipeline]
}

resource "aws_sns_topic_policy" "reports_notifications" {
  arn    = aws_sns_topic.reports_notifications.arn
  policy = data.aws_iam_policy_document.reports_sns_topic_doc.json

  depends_on = [aws_sns_topic.reports_notifications]
}
