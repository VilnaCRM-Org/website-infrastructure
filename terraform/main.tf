terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.46"
    }
  }

  required_version = ">= 1.3.0"
}

provider "aws" {
  region = "eu-central-1"
}