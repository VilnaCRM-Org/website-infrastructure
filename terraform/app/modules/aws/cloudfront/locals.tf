locals {
  s3_origin_id          = "${var.domain_name}-orgin-id"
  s3_failover_origin_id = "${var.domain_name}-failover-orgin-id"
  account_id            = data.aws_caller_identity.current.account_id
}