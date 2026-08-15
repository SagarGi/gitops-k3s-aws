provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = "GitOps-K3s-Platform"
    }
  }
}

# NOTE: For initial `terraform init`, comment out this backend block.
# Once you create your S3 bucket in AWS, uncomment this block and run `terraform init -migrate-state`.
# terraform {
#   backend "s3" {
#     bucket         = "YOUR-UNIQUE-TERRAFORM-STATE-BUCKET-NAME"
#     key            = "dev/terraform.tfstate"
#     region         = "eu-north-1"
#     encrypt        = true
#   }
# }