data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

#<----------Defining the AWS provider and region---------->#
provider "aws" {
  region = var.aws_region
}

#<----------Defining VPC---------->#
resource "aws_vpc" "compute_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.project_name}-vpc"
  }
}

#<----------Defining public subnet---------->#
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.compute_vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

}

#<----------Defining Internet Gateway---------->#
resource "aws_internet_gateway" "compute_igw" {
  vpc_id = aws_vpc.compute_vpc.id

  tags = {
    Name = "${local.project_name}-igw"
  }
}

#<------------------Defining Route Table---------->#
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.compute_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.compute_igw.id
  }

  tags = {
    Name = "${local.project_name}-public-rt"
  }
}

#<------------------Defining Route Association---------->#
resource "aws_route_table_association" "public_route_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

#<------------------Defining Security Group---------->#
resource "aws_security_group" "compute_sg" {
  name        = "${local.project_name}-sg"
  description = "Security group for compute instances"
  vpc_id      = aws_vpc.compute_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ingress_cidr]
  }

  tags = {
    Name = "${local.project_name}-sg"
  }
}

#<----------Defining Instance---------->#
resource "aws_instance" "compute_instance" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.compute_key.key_name
  vpc_security_group_ids      = [aws_security_group.compute_sg.id]

  user_data_replace_on_change = true

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail
    
    dnf install -y nginx
    systemctl enable --now nginx

    cat > /usr/share/nginx/html/index.html << 'HTML'
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
        <title>AWS Network and Compute</title>
    </head>
    <body>
      <h1> Welcome to AWS Network and Compute Project</h1>
      <p> Deployed using Terraform on Amazon Linux 2023.</p>
      <p> Region: ap-south-2</p>
    </body>
    </html>
    HTML
  EOF

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "${local.project_name}-instance"
  }
}

#<----------Defining Key Pair---------->#
resource "aws_key_pair" "compute_key" {
  key_name = "${local.project_name}-key"
  public_key = file(
    pathexpand("C:/Users/MAGESH/.ssh/compute_key.pub")
  )
}
