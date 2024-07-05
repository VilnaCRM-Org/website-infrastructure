variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "website_project_name" {
  description = "Unique name for the Website Codepipeline"
  type        = string
}

variable "ci_cd_project_name" {
  description = "Unique name for the CI/CD Codepipeline"
  type        = string
}

variable "ci_cd_website_project_name" {
  description = "Unique name for this Website Deploy Codepipeline"
  type        = string
}

variable "policy_prefix" {
  description = "Policy Prefix for policies"
  type        = string
}

variable "environment" {
  description = "Environment for the project"
  type        = string
}

variable "region" {
  description = "Region for the project"
  type        = string
}

variable "tags" {
  description = "Tags to be attached to the resource"
  type        = map(any)
}