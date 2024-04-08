variable "frontend_user_group_name" {
  description = "Unique name for this FrontEnd User Group"
  type        = string
}

variable "frontend_user_group_path" {
  description = "Unique path for this FrontEnd User Group"
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

