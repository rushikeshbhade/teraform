terraform {
  required_version = "~> 1.3.0"

  backend "s3" {
    bucket  = "aws-304188066464-us-east-2-terraform-remote-state"
    key     = "dev/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

    random = {
      source = "hashicorp/random"
    }
  }
}
