resource "aws_iam_role" "codepipeline_role_sandbox" {
  name = "${var.project_name}${var.codepipeline_role_name_suffix}${var.environment}"
  tags = {
    Environment = var.environment
    Purpose     = "sandbox-deletion"
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
}

variable "codepipeline_role_name_suffix" {
  description = "Suffix for the CodePipeline role name"
  type        = string
  default     = "-codepipeline-role-sandbox-deletion-"
}

resource "aws_iam_role" "codebuild_role_sandbox" {
  name = "${var.project_name}${var.codebuild_role_name_suffix}${var.environment}"
  tags = {
    Environment = var.environment
    Purpose     = "sandbox-deletion"
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

variable "codebuild_role_name_suffix" {
  description = "Suffix for the CodeBuild role name"
  type        = string
  default     = "-codebuild-role-sandbox-deletion-"
}