terraform {
  required_version = ">= 1.3"
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
  }
}
