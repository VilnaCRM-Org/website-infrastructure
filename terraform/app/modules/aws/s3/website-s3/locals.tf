locals {
  s3_bucket_name = var.s3_bucket_custom_name == "" ? var.domain_name : var.s3_bucket_custom_name
}