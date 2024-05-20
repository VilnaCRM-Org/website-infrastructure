variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "tags" {
  description = "Tags to be attached to the CodePipeline"
  type        = map(any)
}

variable "canaries_reports_bucket_id" {
  description = "Canaries Reports Bucket ID"
  type        = string
}

variable "canaries_iam_role_arn" {
  description = "Canaries IAM role ARN"
  type        = string
}

variable "canary_configuration" {
  type        = map(any)
  description = "Apply public access block to S3 bucket?"
}

variable "domain_name" {
  type        = string
  description = "Domain name for website, used for all resources"
}

variable "path_to_canary" {
  type        = string
  description = "Path to Canary Content"
  default     = "../../../../../../aws/canary/py"
}

