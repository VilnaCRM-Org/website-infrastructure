variable "github_connection_name" {
  description = "Name of the CodeStar connection"
  type        = string
}

variable "tags" {
  description = "Tags to be attached to the CodePipeline"
  type        = map(any)
}