resource "aws_lambda_function" "s3_cleanup_lambda" {
  #checkov:skip=CKV_AWS_117:AWS VPC is not needed here for sending notifications
  #checkov:skip=CKV_AWS_50: X-Ray is not needed for such lambda and it takes bonus costs
  #checkov:skip=CKV_AWS_116: DLQ needs additional topics, to complex for simple redirect lambda function
  #checkov:skip=CKV_AWS_272: Code-signing is not needed for simple redirect lambda function
  #checkov:skip=CKV_AWS_173: KMS encryption is not needed
  #checkov:skip=CKV_AWS_115: exclude in testing purposes
  #ts:skip=AWS.LambdaFunction.Logging.0472 AWS VPC is not needed here for sending notifications
  #ts:skip=AWS.LambdaFunction.Logging.0470 X-Ray is not needed for such lambda and it takes bonus costs
  function_name = "s3-cleanup-lambda"
  role          = aws_iam_role.lambda_cleanup_function_role.arn
  runtime       = "python3.9"
  handler       = "s3_cleanup.lambda_handler"
  timeout       = 15

  filename = "${var.path_to_lambdas}/zip/s3_cleanup_function_payload.zip"

  depends_on = [
    aws_iam_role.lambda_cleanup_function_role,
    aws_iam_policy.s3_cleanup_function_policy
  ]
}