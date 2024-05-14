resource "aws_cloudwatch_log_group" "dynamodb_terraform_group" {
  #checkov:skip=CKV_AWS_338: The one year is too much 
  name              = "${var.project_name}-aws-dynamodb-terraform-group"
  retention_in_days = var.cloudwatch_log_group_retention_days
  kms_key_id        = aws_kms_key.cloudwatch_encryption_key.arn

  depends_on = [aws_kms_key_policy.cloudwatch_encryption_key]
}

resource "aws_cloudtrail" "dynamodb_cloudtrail" {
  name                          = "${var.project_name}-dynamodb-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.id
  s3_key_prefix                 = "dynamodb-cloudtrail"
  include_global_service_events = false
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

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.dynamodb_terraform_group.arn}:*" # CloudTrail requires the Log Stream wildcard
  cloud_watch_logs_role_arn = aws_iam_role.iam_for_cloudtrail.arn

  depends_on = [aws_s3_bucket_policy.cloudtrail_bucket_policy, aws_iam_role_policy_attachment.cloudtrail_allow_logging_policy_attachment]
}