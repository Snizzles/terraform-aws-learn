
variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "instance_ami" {
  description = "The AMI ID for the EC2 instance."
  type        = string
  default     = "ami-0644d0c7fe285b225" # Your ARM Amazon Linux 2023
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
  default     = "t4g.micro"
}