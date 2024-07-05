resource "aws_iam_role_policy_attachment" "codebuild_policy_role_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
  depends_on = [aws_iam_role.codebuild_role, aws_iam_policy.codebuild_policy]
}