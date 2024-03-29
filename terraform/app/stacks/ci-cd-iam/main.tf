module "codepipeline-user" {
  source = "../../modules/aws/iam/users/codepipeline-deploy-user"

  project_name = var.project_name
  region       = var.region
  environment  = var.environment

  tags = var.tags
}