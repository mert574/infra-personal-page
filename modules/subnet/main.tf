resource "aws_subnet" "app-subnet" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.environment}-app-subnet"
  }
}

resource "aws_internet_gateway" "app-igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.environment}-app-igw"
  }
}

resource "aws_default_route_table" "app-rtb" {
  default_route_table_id = var.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app-igw.id
  }

  tags = {
    Name = "${var.environment}-app-rtb"
  }
}
