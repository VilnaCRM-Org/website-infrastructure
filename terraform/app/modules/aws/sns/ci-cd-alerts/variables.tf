variable "project_name" {
  description = "Unique name for the project"
  type        = string
}

variable "cloudwatch_alarms_arns" {
  description = "CloudWatch Alarms"
  type        = list(string)
}

variable "tags" {
  description = "Tags to be associated with the CI/CD Infrastructure"
  type        = map(any)
}