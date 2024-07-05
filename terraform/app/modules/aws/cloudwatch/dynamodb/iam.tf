resource "aws_iam_role" "iam_for_cloudtrail" {
  name               = "${var.project_name}-iam-for-cloudtrail"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json
}

resource "aws_iam_policy" "cloudtrail_allow_logging_policy" {
  name        = "${var.project_name}-iam-policy-allow-logging-for-cloudtrail"
  description = "A policy that allows send logs from Cloudtrail to Cloudwatch"
  policy      = data.aws_iam_policy_document.cloudtrail_allow_logging.json
}

resource "aws_iam_role_policy_attachment" "cloudtrail_allow_logging_policy_attachment" {
  role       = aws_iam_role.iam_for_cloudtrail.name
  policy_arn = aws_iam_policy.cloudtrail_allow_logging_policy.arn
}