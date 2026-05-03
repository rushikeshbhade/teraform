terraform {
  required_version = "~> 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.20"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
  backend "s3" {
    bucket  = "aws-304188066464-us-east-2-terraform-remote-state"
    key     = "dev/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}
