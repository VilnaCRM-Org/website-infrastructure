locals {
  account_id                                 = var.account_id
  partition                                  = var.partition
  region                                     = var.region
  lambda_reports_notifications_function_name = "${var.project_name}-reports-notification"
  lambda_reports_notifications_function_arn  = "arn:${local.partition}:lambda:${local.region}:${local.account_id}:function:${local.lambda_reports_notifications_function_name}"
  codepipeline_notifications_topic_name      = "${var.project_name}-notifications"
  reports_notifications_topic_name           = "${var.project_name}-reports-notifications"
  codepipeline_notifications_topic_arn       = "arn:${local.partition}:sns:${local.region}:${local.account_id}:${local.codepipeline_notifications_topic_name}"
  reports_notifications_topic_arn            = "arn:${local.partition}:sns:${local.region}:${local.account_id}:${local.reports_notifications_topic_name}"
}
