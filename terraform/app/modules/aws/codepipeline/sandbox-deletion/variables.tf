variable "project_name" { 
  description = "The name of the project used for resource naming"
  type = string 
}

variable "codepipeline_role_arn" { 
  type = string 
}

variable "s3_bucket_arn" { 
  type = string 
}

variable "codestar_connection_arn" {
  type = string 
}

variable "source_repo_owner" {
  type = string 
}

variable "source_repo_name" { 
  type = string 
}

variable "source_repo_branch" { 
  type = string 
}

variable "codebuild_project_name" { 
  type = string 
}

variable "region" { 
  type = string 
}
