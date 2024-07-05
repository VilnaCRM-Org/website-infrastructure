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

variable "web_acl_name" {
  description = "Name of Web ACL"
  type        = string
}

variable "waf_log_group_name" {
  description = "Name of the WAF2 Log Group"
  type        = string
}