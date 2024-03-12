data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${var.path_to_lambdas}/sns_converter.py"
  output_path = "lambda_function_payload.zip"
}

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

resource "aws_lambda_permission" "allow_replication_bucket" {
  statement_id  = "AllowExecutionFromReplicationS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.func.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.replication_bucket.arn
}

resource "aws_lambda_function" "func" {
  filename      = "lambda_function_payload.zip"
  function_name = "${var.project_name}-lambda-func"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "sns_converter.lambda_handler"
  runtime       = "python3.12"

  environment {
    variables = {
      SNS_TOPIC_ARN = "${aws_sns_topic.bucket_notifications.arn}"
    }
  }
}