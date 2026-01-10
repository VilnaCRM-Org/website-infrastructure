locals {
  account_id     = coalesce(var.account_id, data.aws_caller_identity.current.account_id)
  partition      = coalesce(var.partition, data.aws_partition.current.partition)
  sns_topic_name = "${var.project_name}-notifications"
  sns_topic_arn  = "arn:${local.partition}:sns:${var.region}:${local.account_id}:${local.sns_topic_name}"
}
