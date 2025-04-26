terraform {
  backend "s3" {
    bucket = "resume-editor-terraform-state-bucket"
    key    = "state/resume-api-ec2-state.tfstate"
    region = "ap-southeast-2"
  }
}

# Provider configuration
provider "aws" {
  region = "ap-southeast-2"  
}

# Create a security group in the default VPC
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Add rule for HTTP traffic on port 3000
  ingress {
    description = "HTTP on port 3000"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }
    # Add rule for HTTP traffic on port 3000
  ingress {
    description = "HTTP on port 3001"
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  # Add rule for HTTP traffic on port 3000
  ingress {
    description = "HTTP on port 5000"
    from_port   = 5000 
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }
  # Add rule for HTTP traffic on port 3000
  ingress {
    description = "HTTP on port 5001"
    from_port   = 5001 
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

# Generate a key pair
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("${path.module}/id_ed.pub")
}

# Launch EC2 instance in the default VPC
resource "aws_instance" "web" {
  ami           = "ami-04b3f96fa99d40135"  # Amazon Machine Image
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  root_block_device {
    volume_size = 20  # Set the root volume size to 20GB
  }

  tags = {
    Name = "resumeApi"
  }
}

# Output the public IP of the instance
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip
}
