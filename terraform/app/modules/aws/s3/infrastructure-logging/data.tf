data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_iam_policy_document" "logging_bucket_policy_doc" {
  dynamic "statement" {
    for_each = var.access_log_source_bucket_names

    content {
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = ["logging.s3.amazonaws.com"]
      }

      actions   = ["s3:PutObject"]
      resources = ["${aws_s3_bucket.logging_bucket.arn}/s3-access-logs/${statement.value}/*"]

      condition {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = [data.aws_caller_identity.current.account_id]
      }

      condition {
        test     = "ArnEquals"
        variable = "aws:SourceArn"
        values   = ["arn:${data.aws_partition.current.partition}:s3:::${statement.value}"]
      }
    }
  }

  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.logging_bucket.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:trail/${var.project_name}-dynamodb-cloudtrail"]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.logging_bucket.arn}/dynamodb-cloudtrail/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:trail/${var.project_name}-dynamodb-cloudtrail"]
    }
  }
}
