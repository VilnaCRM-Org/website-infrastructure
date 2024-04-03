variable "website_project_name" {
  description = "Unique name for this Website Codepipeline"
  type        = string
}

variable "ci_cd_project_name" {
  description = "Unique name for this CI/CD Codepipeline"
  type        = string
}

variable "policy_prefix" {
  description = "Policy Prefix for policies"
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