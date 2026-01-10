terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.25.0"
      configuration_aliases = [aws.us-east-1, aws.eu-west-1]
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = "0.69.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.4.2"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}
