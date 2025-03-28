resource "aws_lambda_function" "sandbox_cleanup_lambda" {
  #checkov:skip=CKV_AWS_117:AWS VPC is not needed here for sending notifications
  #checkov:skip=CKV_AWS_50: X-Ray is not needed for such lambda and it takes bonus costs
  #checkov:skip=CKV_AWS_116: DLQ needs additional topics, too complex for sandbox cleanup lambda function
  #checkov:skip=CKV_AWS_272: Code-signing is not needed for sandbox cleanup lambda function
  #checkov:skip=CKV_AWS_173: KMS encryption is not needed
  #ts:skip=AWS.LambdaFunction.Logging.0472 AWS VPC is not needed here for sending notifications
  #ts:skip=AWS.LambdaFunction.Logging.0470 X-Ray is not needed for such lambda and it takes bonus costs
  function_name                  = "sandbox-cleanup-lambda"
  role                           = aws_iam_role.sandbox_cleanup_function_role.arn
  runtime                        = var.lambda_python_version
  handler                        = "sandbox_cleanup.lambda_handler"
  timeout                        = 300
  memory_size                    = 256
  reserved_concurrent_executions = var.lambda_reserved_concurrent_executions

  filename = "${var.path_to_lambdas}/zip/sandbox_cleanup_function_payload.zip"

  depends_on = [
    aws_iam_role.sandbox_cleanup_function_role,
    aws_iam_policy.sandbox_cleanup_function_policy
  ]
}

resource "aws_iam_role" "sandbox_cleanup_function_role" {
  name = "sandbox-cleanup-function-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "sandbox_cleanup_function_policy" {
  name        = "sandbox-cleanup-function-policy"
  description = "Allows Lambda to manage S3 buckets and objects"

  policy = data.aws_iam_policy_document.sandbox_cleanup_function_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_sandbox_cleanup_attach" {
  role       = aws_iam_role.sandbox_cleanup_function_role.name
  policy_arn = aws_iam_policy.sandbox_cleanup_function_policy.arn
}