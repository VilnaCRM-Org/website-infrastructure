module "codestar_connection" {
  source = "../../modules/aws/codestar"

  github_connection_name = var.github_connection_name

  tags = var.tags
}