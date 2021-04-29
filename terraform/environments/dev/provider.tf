terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

//  backend "s3" {
//    bucket  = "tfstate"
//    key     = "terraform.tfstate"
//    region  = "ap-northeast-1"
//  }
}

# Configure the AWS Provider
provider "aws" {
  region = lookup(var.aws_base_config, "region")
  profile = lookup(var.aws_base_config, "profile")
}
