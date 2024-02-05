locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  create_test_env_slack_notification = var.environment == "test" ? 0 : 1
}

