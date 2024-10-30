resource "aws_iam_policy" "codepipeline_policy" {
  name        = "${var.project_name}-codepipeline-policy"
  description = "Policy for CodePipeline permissions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codepipeline:StartPipelineExecution",
          "codepipeline:PutJobSuccessResult",
          "codepipeline:PutJobFailureResult",
          "codepipeline:GetPipelineState",
          "codepipeline:GetPipelineExecution",
          "codepipeline:GetPipeline",
          "codepipeline:ListPipelineExecutions",
          "codepipeline:ListPipelines",
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ],
        Resource = [
          "arn:aws:codepipeline:${var.region}:${var.account_id}:${var.project_name}-*",
          "arn:aws:codepipeline:${var.region}:${var.account_id}:${var.project_name}-codepipeline-role-sandbox-deletion-${var.environment}",
          "arn:aws:codebuild:${var.region}:${var.account_id}:project/sandbox-${var.environment}-deletion"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "codestar-connections:UseConnection"
        ],
        Resource = [
          "${var.codestar_connection_arn}"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:DeleteBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.project_name}-codepipeline-artifacts-${var.environment}",
          "arn:aws:s3:::${var.project_name}-codepipeline-artifacts-${var.environment}/*",
          "arn:aws:s3:::${var.project_name}-codebuild-logs-${var.environment}",
          "arn:aws:s3:::${var.project_name}-codebuild-logs-${var.environment}/*",
          "arn:aws:s3:::${var.project_name}-access-logs-${var.environment}",
          "arn:aws:s3:::sandbox-${var.environment}-*",
          "arn:aws:s3:::sandbox-${var.environment}-*/*"
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
          "codebuild:BatchGetProjects"
        ],
        Resource = [
          "arn:aws:codebuild:${var.region}:${var.account_id}:project/${var.project_name}-*",
          "arn:aws:codepipeline:${var.region}:${var.account_id}:${var.project_name}-codepipeline-role-sandbox-deletion-${var.environment}"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/codebuild/sandbox-${var.environment}-deletion:*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:DeleteBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.project_name}-codepipeline-artifacts-${var.environment}",
          "arn:aws:s3:::${var.project_name}-codebuild-logs-${var.environment}",
          "arn:aws:s3:::${var.project_name}-access-logs-${var.environment}",
          "arn:aws:s3:::${var.project_name}-codepipeline-artifacts-${var.environment}/*",
          "arn:aws:s3:::${var.project_name}-codebuild-logs-${var.environment}/*",
          "arn:aws:s3:::${var.project_name}-access-logs-${var.environment}/*",
          "arn:aws:s3:::sandbox-${var.environment}-*",
          "arn:aws:s3:::sandbox-${var.environment}-*/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "codestar-connections:UseConnection"
        ],
        Resource = [
          "${var.codestar_connection_arn}"
        ]
      }
    ]
  })
}