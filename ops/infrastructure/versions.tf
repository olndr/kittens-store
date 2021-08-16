terraform {
  # pin terraform version
  required_version = "1.0.2"

  # required providers for our bootcamp with version pinning
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}