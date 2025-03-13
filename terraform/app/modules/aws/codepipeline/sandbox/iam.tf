resource "aws_iam_role" "lambda_execution_role" {
  name = "s3_cleanup_lambda_role"

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

resource "aws_iam_policy" "s3_cleanup_policy" {
  name        = "s3_cleanup_policy"
  description = "Allows Lambda to manage S3 buckets and objects"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:ListBucket",
          "s3:GetBucketLifecycleConfiguration",
          "s3:PutBucketLifecycleConfiguration",
          "s3:DeleteBucket",
          "s3:DeleteObject",
          "s3:ListBucketVersions",
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_cleanup_attach" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.s3_cleanup_policy.arn
}