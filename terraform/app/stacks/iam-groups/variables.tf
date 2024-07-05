variable "frontend_user_group_name" {
  description = "Unique name for FrontEnd User Group"
  type        = string
}

variable "frontend_user_group_path" {
  description = "Unique path for FrontEnd User Group"
  type        = string
}

variable "devops_user_group_name" {
  description = "Unique name for DevOps User Group"
  type        = string
}

variable "devops_user_group_path" {
  description = "Unique path for DevOps User Group"
  type        = string
}

variable "backend_user_group_name" {
  description = "Unique name for Backend User Group"
  type        = string
}

variable "backend_user_group_path" {
  description = "Unique path for Backend User Group"
  type        = string
}

variable "qa_user_group_name" {
  description = "Unique name for QA User Group"
  type        = string
}

variable "qa_user_group_path" {
  description = "Unique path for QA User Group"
  type        = string
}

variable "admin_user_group_name" {
  description = "Unique name for Admin User Group"
  type        = string
}

variable "admin_user_group_path" {
  description = "Unique path for Admin User Group"
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

