resource "aws_iam_role_policy_attachment" "codepipeline_policy_role_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
  depends_on = [aws_iam_role.codepipeline_role, aws_iam_policy.codepipeline_policy]
}