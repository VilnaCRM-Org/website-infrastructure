locals {
  account_id = data.aws_caller_identity.current.account_id
  allow_force_destroy = var.environment == "test" ? true : false
}