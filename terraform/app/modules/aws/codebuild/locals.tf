locals {
  stack = var.project_name == "website-infra-test" ? "website" : "ci-cd-infrastructure"
}
