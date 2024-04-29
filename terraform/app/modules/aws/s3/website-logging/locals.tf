locals {
  allow_force_destroy = var.environment == "test" ? true : false
}