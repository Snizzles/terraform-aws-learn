# This block tells Terraform we need the AWS provider from HashiCorp
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# This configures the AWS provider, telling it which region to build things in.
provider "aws" {
  region = "us-east-1"
}

# This is the "blueprint" for our S3 bucket resource.
resource "aws_s3_bucket" "my_first_bucket" {
  # BUCKET NAMES MUST BE GLOBALLY UNIQUE. Change the name below!
  bucket = "october3bucketforme"

  tags = {
    Name        = "My first Terraform bucket"
    Environment = "Dev"
  }
}

# This is a separate security resource to ensure the bucket is not public.
resource "aws_s3_bucket_public_access_block" "my_bucket_pab" {
  bucket = aws_s3_bucket.my_first_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# This tells Terraform to output the bucket's name after it's created.
output "bucket_name" {
  value       = aws_s3_bucket.my_first_bucket.bucket
  description = "The name of the S3 bucket."
}