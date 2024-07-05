resource "aws_cloudwatch_log_group" "waf_web_acl_log_group" {
  #checkov:skip=CKV_AWS_338: The one year is too much 
  provider          = aws.us-east-1
  name              = "aws-waf-logs-wafv2-web-acl"
  retention_in_days = 60
  kms_key_id        = aws_kms_key.cloudwatch_encryption_key.arn

  depends_on = [aws_kms_key_policy.cloudwatch_encryption_key]
}