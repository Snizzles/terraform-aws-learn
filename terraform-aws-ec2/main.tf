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
  tags = {
    Name = "main-subnet"
  }
}

# --- Security ---

# Use a data source to automatically find your current IP address
data "http" "my_ip" {
  url = "http://ipv4.icanhazip.com"
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
  ami           = "ami-0644d0c7fe285b225" # Your new ARM-based Amazon Linux 2023 AMI
  instance_type = "t4g.micro"            # A free-tier eligible ARM instance type

  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "ExampleWebServer"
  }
}

# --- Output ---

output "instance_public_ip" {
  value       = aws_instance.web_server.public_ip
  description = "The public IP address of the web server instance."
}