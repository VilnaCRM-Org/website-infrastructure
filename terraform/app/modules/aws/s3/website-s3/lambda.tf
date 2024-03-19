resource "aws_iam_role" "iam_for_lambda" {
  name               = "${var.project_name}-iam-for-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_policy" "lambda_allow_sns_policy" {
  name        = "${var.project_name}-iam-policy-allow-sns-for-lambda"
  description = "A policy that allows send messages from Lambda to SNS"
  policy      = data.aws_iam_policy_document.lambda_allow_sns_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_allow_sns_policy_attachment" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_allow_sns_policy.arn
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.func.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.this.arn
}

resource "aws_lambda_function" "func" {
  #checkov:skip=CKV_AWS_117:AWS VPC is not needed here for sending notifications
  #checkov:skip=CKV_AWS_50: X-Ray is not needed for such lambda and it takes bonus costs
  #checkov:skip=CKV_AWS_116: DLQ needs additional topics, to complex for simple redirect lambda function
  #checkov:skip=CKV_AWS_272: Code-signing is not needed for simple redirect lambda function 
  #ts:skip=AWS.LambdaFunction.Logging.0472 AWS VPC is not needed here for sending notifications
  #ts:skip=AWS.LambdaFunction.Logging.0470 X-Ray is not needed for such lambda and it takes bonus costs
  filename                       = "${var.path_to_lambdas}/zip/lambda_function_payload.zip"
  function_name                  = "${var.project_name}-lambda-func"
  role                           = aws_iam_role.iam_for_lambda.arn
  handler                        = "sns_converter.lambda_handler"
  runtime                        = var.lambda_python_version
  reserved_concurrent_executions = var.lambda_reserved_concurrent_executions

  kms_key_arn = aws_kms_key.lambda_encryption_key.arn

  environment {
    variables = {
      SNS_TOPIC_ARN = "${aws_sns_topic.bucket_notifications.arn}"
      PRINCIPAL_ID = "${data.aws_caller_identity.current.user_id}"
    }
  }
}