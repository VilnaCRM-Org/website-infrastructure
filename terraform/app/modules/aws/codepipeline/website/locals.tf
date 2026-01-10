locals {
  account_id = coalesce(var.account_id, data.aws_caller_identity.current.account_id)
  partition  = coalesce(var.partition, data.aws_partition.current.partition)
  region     = coalesce(var.region, data.aws_region.current.name)
  lambda_reports_notifications_function_name = "${var.project_name}-reports-notification"
  lambda_reports_notifications_function_arn  = "arn:${local.partition}:lambda:${local.region}:${local.account_id}:function:${local.lambda_reports_notifications_function_name}"
  codepipeline_notifications_topic_name      = "${var.project_name}-notifications"
  reports_notifications_topic_name           = "${var.project_name}-reports-notifications"
  codepipeline_notifications_topic_arn       = "arn:${local.partition}:sns:${local.region}:${local.account_id}:${local.codepipeline_notifications_topic_name}"
  reports_notifications_topic_arn            = "arn:${local.partition}:sns:${local.region}:${local.account_id}:${local.reports_notifications_topic_name}"
}
