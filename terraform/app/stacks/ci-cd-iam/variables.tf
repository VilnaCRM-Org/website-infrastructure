variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "environment" {
  description = "Environment for this project"
  type        = string
}

variable "region" {
  description = "Region for this project"
  type        = string
}


variable "tags" {
  description = "Tags to be attached to the resource"
  type        = map(any)
}