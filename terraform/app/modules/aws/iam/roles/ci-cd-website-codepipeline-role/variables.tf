variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "region" {
  description = "Region for this project"
  type        = string
}

variable "environment" {
  description = "Environment for this project"
  type        = string
}

variable "source_repo_owner" {
  description = "Source repo owner of the GitHub repository"
  type        = string
}

variable "source_repo_name" {
  description = "Source repo name of the repository"
  type        = string
}

variable "codepipeline_iam_role_name" {
  description = "Name of the IAM role to be used by the project"
  type        = string
}

variable "tags" {
  description = "Tags to be attached to the IAM Role"
  type        = map(any)
}

variable "website_bucket_name" {
  description = "The Name of the domain S3 Bucket "
  type        = string
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 Bucket"
  type        = string
}

variable "lhci_reports_bucket_arn" {
  description = "The ARN of the Lighthouse Reports S3 Bucket "
  type        = string
}

variable "test_reports_bucket_bucket_arn" {
  description = "The ARN of the Test Reports S3 Bucket "
  type        = string
}

variable "codestar_connection_arn" {
  description = "The ARN of the CodeStar connection"
  type        = string
}