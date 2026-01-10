locals {
  account_id     = var.account_id
  sns_topic_name = "${var.project_name}-notifications"
  sns_topic_arn  = "arn:${var.partition}:sns:${var.region}:${local.account_id}:${local.sns_topic_name}"
}
