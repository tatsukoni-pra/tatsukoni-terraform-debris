terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.98.0"
    }
  }
  backend "s3" {
    bucket  = "tatsukoni-tfstates"
    key     = "aws/container-scan-demo.tfstate"
    region  = "ap-northeast-1"
    profile = "tatsukoni"
  }
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "tatsukoni"
  default_tags {
    tags = {
      RepositoryFilePath = "aws/container-scan-demo"
    }
  }
}
