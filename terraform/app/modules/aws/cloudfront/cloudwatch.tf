resource "aws_cloudwatch_log_group" "waf_web_acl_log_group" {
  #checkov:skip=CKV_AWS_338: The one year is too much
  #checkov:skip=CKV_AWS_158: KMS encryption is not needed
  provider          = aws.us-east-1
  name              = "aws-waf-logs-wafv2-web-acl"
  retention_in_days = 60

}