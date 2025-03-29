terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "5.93.0"
      configuration_aliases = [aws.japan]
    }
  }
}

provider "aws" {
  # Configuration options
  region  = "ap-southeast-1"
  profile = var.profile
}

provider "aws" {
  # Configuration options
  region  = "ap-northeast-1"
  profile = var.profile
  alias   = "japan"
}