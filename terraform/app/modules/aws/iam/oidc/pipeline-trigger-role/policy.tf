resource "aws_iam_policy" "codepipeline_trigger_policy" {
  name = "${var.role_name}-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codepipeline:StartPipelineExecution",
          "codepipeline:GetPipelineState"
        ]
        Resource = var.pipeline_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_trigger_role_attachment" {
  role       = aws_iam_role.codepipeline_trigger_role.name
  policy_arn = aws_iam_policy.codepipeline_trigger_policy.arn
}