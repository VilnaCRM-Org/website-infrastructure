variable "project_name" {
  description = "Unique name for this project"
  type        = string
}
variable "website_user_group_name" {
  description = "Unique name for this Website User Group"
  type        = string
}

variable "website_user_group_path" {
  description = "Unique path for this Website User Group"
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

variable "domain_name" {
  type        = string
  description = "Domain name for website, used for all resources"
}

variable "tags" {
  description = "Tags to be attached to the resource"
  type        = map(any)
}

