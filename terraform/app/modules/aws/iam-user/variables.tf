variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "codepipeline_terraform_arn" {
  description = "ARN of terraform codepipeline"
  type        = string
}

variable "tags" {
  description = "Tags to be attached to the IAM User"
  type        = map(any)
}