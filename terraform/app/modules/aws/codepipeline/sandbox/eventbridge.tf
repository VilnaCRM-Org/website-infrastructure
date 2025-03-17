resource "aws_cloudwatch_event_rule" "s3_cleanup_rule" {
  name                = "s3-cleanup-rule"
  description         = "Triggers Lambda to delete S3 buckets"
  schedule_expression = "rate(10 minutes)"
  
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_cloudwatch_event_target" "s3_cleanup_target" {
  rule      = aws_cloudwatch_event_rule.s3_cleanup_rule.name
  target_id = "s3-cleanup-lambda"
  arn       = aws_lambda_function.s3_cleanup_lambda.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_cleanup_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_cleanup_rule.arn
}