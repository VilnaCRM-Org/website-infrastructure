resource "aws_cloudwatch_log_group" "dynamodb_terraform_group" {
  #checkov:skip=CKV_AWS_338: The one year is too much
  #checkov:skip=CKV_AWS_158: KMS encryption is not needed
  name              = "${var.project_name}-aws-dynamodb-terraform-group"
  retention_in_days = var.cloudwatch_log_group_retention_days
}

resource "aws_cloudtrail" "dynamodb_cloudtrail" {
  #checkov:skip=CKV_AWS_67: All Regions is not needed, only for DynamoDB
  #checkov:skip=CKV_AWS_252: SNS is not needed here
  #checkov:skip=CKV_AWS_35: KMS encryption is not needed
  #ts:skip=AC_AWS_0448 All Regions is not needed, only for DynamoDB
  name                          = "${var.project_name}-dynamodb-cloudtrail"
  s3_bucket_name                = var.logging_bucket_id
  s3_key_prefix                 = "dynamodb-cloudtrail"
  include_global_service_events = false

  enable_log_file_validation = true

  advanced_event_selector {
    name = "Log all DynamoDB Item actions for a terraform-locks DynamoDB table"

    field_selector {
      field  = "eventCategory"
      equals = ["Data"]
    }

    field_selector {
      field = "resources.type"

      equals = [
        "AWS::DynamoDB::Table"
      ]
    }

    field_selector {
      field  = "eventName"
      equals = ["PutItem", "GetItem", "DeleteItem"]
    }

    field_selector {
      field = "resources.ARN"

      equals = [
        data.aws_dynamodb_table.table.arn
      ]
    }
  }

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.dynamodb_terraform_group.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.iam_for_cloudtrail.arn

  depends_on = [aws_iam_role_policy_attachment.cloudtrail_allow_logging_policy_attachment]
}