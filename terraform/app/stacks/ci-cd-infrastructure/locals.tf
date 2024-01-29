locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  stages_to_create        = var.environment != "prod" ? var.stage_input : slice(var.stage_input, 0, length(var.stage_input) - 1)
  build_project_to_create = var.environment != "prod" ? var.build_projects : slice(var.build_projects, 0, length(var.build_projects) - 1)
}

