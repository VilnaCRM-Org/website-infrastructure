variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of KMS key for encryption"
  type        = string
}

variable "channel_id" {
  description = "Channel ID of Slack"
  type        = string
}

variable "workspace_id" {
  description = "Workspace ID of Slack"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS Topic Arn"
  type        = string
}

variable "tags" {
  description = "Tags to be attached to the CodePipeline"
  type        = map(any)
}
