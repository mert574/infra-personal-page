provider "aws" {}

variable "environment" {}
variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "availability_zone" {}
variable "my_ip" {}

resource "aws_vpc" "app-vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.environment}-app-vpc"
  }
}

resource "aws_subnet" "app-subnet" {
  vpc_id            = aws_vpc.app-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.environment}-app-subnet"
  }
}

resource "aws_internet_gateway" "app-igw" {
  vpc_id = aws_vpc.app-vpc.id

  tags = {
    Name = "${var.environment}-app-igw"
  }
}

resource "aws_default_route_table" "app-rtb" {
  default_route_table_id = aws_vpc.app-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app-igw.id
  }

  tags = {
    Name = "${var.environment}-app-rtb"
  }
}

resource "aws_default_security_group" "app-sg" {
  vpc_id = aws_vpc.app-vpc.id

  ingress {
    description = "Allow SSH from my_ip"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "Allow connections to 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description     = "Allow outbound connections"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.environment}-app-default-sg"
  }
}
