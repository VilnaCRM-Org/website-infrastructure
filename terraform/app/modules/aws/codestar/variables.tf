variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "tags" {
  description = "Tags to be attached to the CodePipeline"
  type        = map(any)
}