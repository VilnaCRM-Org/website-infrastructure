resource "aws_codestarconnections_connection" "github_connection" {
  name          = "${var.project_name}-codestar"
  provider_type = "GitHub"
  
  tags = var.tags
}
