terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "5.93.0"
      configuration_aliases = [aws.tokyo]
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-southeast-1"
}

provider "aws" {
  # Configuration options
  region = "ap-northeast-1"
  alias  = "tokyo"
}