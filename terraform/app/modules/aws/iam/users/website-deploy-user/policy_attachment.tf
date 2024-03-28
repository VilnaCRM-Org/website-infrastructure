resource "aws_iam_group_policy_attachment" "terraform_policy_attachment" {
  group      = aws_iam_group.website_users.name
  policy_arn = aws_iam_policy.terraform_policy.arn
}
resource "aws_iam_group_policy_attachment" "s3_policy_attachment" {
  group      = aws_iam_group.website_users.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_group_policy_attachment" "dns_policy_attachment" {
  group      = aws_iam_group.website_users.name
  policy_arn = aws_iam_policy.dns_policy.arn
}

resource "aws_iam_group_policy_attachment" "lambda_policy_attachment" {
  group      = aws_iam_group.website_users.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_group_policy_attachment" "kms_policy_attachment" {
  group      = aws_iam_group.website_users.name
  policy_arn = aws_iam_policy.kms_policy.arn
}

resource "aws_iam_group_policy_attachment" "iam_policy_attachment" {
  group      = aws_iam_group.website_users.name
  policy_arn = aws_iam_policy.iam_policy.arn
}

resource "aws_iam_group_policy_attachment" "general_policy_attachment" {
  group      = aws_iam_group.website_users.name
  policy_arn = aws_iam_policy.general_policy.arn
}

resource "aws_iam_group_policy_attachment" "cloudfront_policy_attachment" {
  group      = aws_iam_group.website_users.name
  policy_arn = aws_iam_policy.cloudfront_policy.arn
}
