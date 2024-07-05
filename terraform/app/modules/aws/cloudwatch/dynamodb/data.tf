data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_dynamodb_table" "table" {
  name = var.dynamodb_table_name
}
