resource "aws_lambda_function" "s3_cleanup_lambda" {
  function_name    = "s3-cleanup-lambda"
  role            = aws_iam_role.lambda_execution_role.arn
  runtime         = "python3.9"
  handler         = "s3_cleanup.lambda_handler"

  filename = "${var.path_to_lambdas}/zip/s3_cleanup_function_payload.zip"
}