module "chatbot_codepipelines" {
  count = var.create_slack_notification ? 1 : 0

  source = "../../modules/aws/chatbot"

  project_name = "codepipeline"
  channel_id   = var.CODEPIPELINE_SLACK_CHANNEL_ID
  workspace_id = var.SLACK_WORKSPACE_ID

  sns_topic_arns = [
    module.website_infra_codepipeline.sns_topic_arn,
    module.ci_cd_infra_codepipeline.sns_topic_arn,
    module.ci_cd_website_codepipeline.codepipeline_sns_topic_arn,
  ]

  tags = var.tags

  depends_on = [
    module.website_infra_codepipeline,
    module.ci_cd_infra_codepipeline,
    module.ci_cd_website_codepipeline
  ]
}

module "chatbot_reports" {
  count = var.create_slack_notification ? 1 : 0

  source = "../../modules/aws/chatbot"

  project_name = "reports"
  channel_id   = var.REPORT_SLACK_CHANNEL_ID
  workspace_id = var.SLACK_WORKSPACE_ID

  sns_topic_arns = [
    module.ci_cd_website_codepipeline.reports_sns_topic_arn
  ]

  tags = var.tags

  depends_on = [
    module.ci_cd_website_codepipeline
  ]
}

module "ci_cd_alerts" {
  count = var.create_slack_notification ? 1 : 0

  source = "../../modules/aws/chatbot"

  project_name = "ci-cd-alerts"
  channel_id   = var.CI_CD_ALERTS_SLACK_CHANNEL_ID
  workspace_id = var.SLACK_WORKSPACE_ID

  sns_topic_arns = [
    module.cloudwatch_alerts_sns.cloudwatch_alerts_sns_topic_arn
  ]

  tags = var.tags

  depends_on = [
    module.cloudwatch_alerts_sns
  ]
}