variable "project_name" {
  description = "Unique name for this project"
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

variable "sns_topic_arns" {
  description = "SNS Topic Arns"
  type        = list(string)
}

variable "tags" {
  description = "Tags to be attached to the CodePipeline"
  type        = map(any)
}
