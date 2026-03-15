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

variable "ci_cd_website_stage_names" {
  description = "CodeBuild stage names configured for the website deploy pipeline"
  type        = list(string)
}

variable "region" {
  description = "Region for this project"
  type        = string
}

variable "environment" {
  description = "Environment for this project"
  type        = string
}
