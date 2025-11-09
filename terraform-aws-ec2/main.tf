# Adding Terraform block first
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # The backend block goes INSIDE the terraform block
  backend "s3" {
    bucket         = "snizzles-terraform-state-20251109"
    key            = "projects/ec2/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-project-lock"
    encrypt        = true
  }

}



provider "aws" {
  region = var.aws_region
}

# --- Networking ---

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "main-subnet"
  }
}

# --- Security ---

# Use a data source to automatically find the current IP address
data "http" "my_ip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_from_my_ip"
  description = "Allow SSH inbound traffic from my IP"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22 # SSH port
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- Compute ---

resource "aws_instance" "web_server" {
  ami           = var.instance_ami
  instance_type = var.instance_type            # A free-tier eligible ARM instance type

  associate_public_ip_address = true

  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "ExampleWebServer"
  }
}

