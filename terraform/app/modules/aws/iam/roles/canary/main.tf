resource "aws_iam_role" "canary_role" {
  name               = "${var.project_name}-canary-role"
  assume_role_policy = data.aws_iam_policy_document.canary-assume-role-policy.json
  description        = "IAM role for AWS Synthetic Monitoring Canaries"

  tags = var.tags
}


resource "aws_iam_policy" "canary_policy" {
  name        = "${var.project_name}-canary-policy"
  policy      = data.aws_iam_policy_document.canary-policy.json
  description = "IAM role for AWS Synthetic Monitoring Canaries"

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "canary_policy_attachment" {
  role       = aws_iam_role.canary_role.name
  policy_arn = aws_iam_policy.canary_policy.arn
}