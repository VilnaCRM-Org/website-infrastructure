locals {
  path_to_buildspec = var.environment == "prod" ? "aws/buildspecs/prod" : "aws/buildspecs/test"
}

