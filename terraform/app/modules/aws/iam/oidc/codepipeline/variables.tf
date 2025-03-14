variable "project_name" {
  description = "Unique name for the project"
  type        = string
}

variable "source_repo_owner" {
  description = "Source repo owner of the GitHub repository"
  type        = string
}

variable "source_repo_name" {
  description = "Infrastructure Source repo name of the repository"
  type        = string
}

variable "environment" {
  description = "Environment for the project"
  type        = string
}

variable "ci_cd_website_codepipeline_arn" {
  description = "CodePipeline ARN of CI/CD Website pipeline"
  type        = string
}

variable "ci_cd_website_codepipeline_name" {
  description = "CodePipeline Name of CI/CD Website pipeline"
  type        = string
}

variable "sandbox_codepipeline_arn" {
  description = "CodePipeline ARN of SandBox pipeline"
  type        = string
}

variable "sandbox_codepipeline_name" {
  description = "CodePipeline Name of SandBox pipeline"
  type        = string
}

variable "tags" {
  description = "Tags to be attached to the resource"
  type        = map(any)
}
