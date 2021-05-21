terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    region = "eu-west-1"
    bucket = "930329210350-terraform-state"
    key    = "base/terraform.tfstate"
  }
}

# Configure the AWS Provider
provider "aws" {
  profile = "default"
  region  = var.region
}
