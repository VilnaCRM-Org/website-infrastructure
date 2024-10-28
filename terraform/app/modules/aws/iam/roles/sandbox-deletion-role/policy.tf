resource "aws_iam_policy" "codepipeline_policy" {
  name        = "${var.project_name}-codepipeline-policy"
  description = "Policy for CodePipeline permissions"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codebuild:StartBuild",
          "codepipeline:StartPipelineExecution",
          "codepipeline:PutJobSuccessResult",
          "codepipeline:PutJobFailureResult",
          "codepipeline:GetPipelineState",
          "codepipeline:GetPipelineExecution",
          "codepipeline:GetPipeline",
          "codepipeline:ListPipelineExecutions",
          "codepipeline:ListPipelines",
          "codestar-connections:UseConnection",
          "s3:PutObject",
          "s3:PutObject",
		      "codebuild:StartBuild",
		      "codebuild:BatchGetBuilds",
		      "logs:CreateLogStream",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:DeleteBucket",
        ],
        Resource = [
            "*",
            "arn:aws:s3:::sandbox-test-*",
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "codebuild_policy" {
  name        = "${var.project_name}-codebuild-policy"
  description = "Policy for CodeBuild permissions"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds",
          "codebuild:ListBuilds",
          "codebuild:ListProjects",
          "codebuild:BatchGetProjects",
          "codestar-connections:UseConnection",
          "s3:PutObject",
          "logs:CreateLogStream",
		      "logs:CreateLogGroup",
          "logs:PutLogEvents",
		      "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:DeleteBucket",
        ],
        Resource = [
            "*",
            "arn:aws:s3:::sandbox-test-*",
        ]
      }
    ]
  })
}