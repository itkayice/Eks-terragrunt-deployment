# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    bucket         = "go-app-terragrunt-state-bucket-myapp1234"
    dynamodb_table = "go-app-infra-terraform-lock"
    encrypt        = true
    key            = "./terraform.tfstate"
    profile        = "dev"
    region         = "us-east-1"
  }
}
