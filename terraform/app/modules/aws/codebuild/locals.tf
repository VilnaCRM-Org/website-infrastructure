locals {
  is_prod_or_stage        = var.environment == "prod" || var.environment == "stage" ? 1 : 0
  is_dev_or_test        = var.environment == "test" || var.environment == "dev" ? 1 : 0
  path_to_buildspec = local.is_prod_or_stage == 1 ? "aws/buildspecs/prod-stage" : "aws/buildspecs/dev-test"
}

