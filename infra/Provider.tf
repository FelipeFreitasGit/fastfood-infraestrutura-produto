# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }
#   backend "s3" {
#     bucket  = "tfstate-backend-fast-food-infra-produto"
#     key     = "terraform-deploy.tfstate"
#     region  = "us-east-1"
#     encrypt = true
#   }
# }

# provider "aws" {
#   region = "us-east-1"
# }
