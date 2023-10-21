
locals {
  region  = "us-east-1"
  profile = "dev"
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend  = "s3"
  config   = {
    encrypt        = true
    bucket         = "go-app-terragrunt-state-bucket-myapp1234"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "${local.region}"
    dynamodb_table = "go-app-infra-terraform-lock"
    profile = "${local.profile}"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    provider "aws" {
      region = "${local.region}"
      profile = "${local.profile}"
    }
    EOF
}
