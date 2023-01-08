provider "aws" {}

resource "aws_vpc" "app-vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.environment}-app-vpc"
  }
}

module "app-subnet" {
  source                 = "./modules/subnet"
  subnet_cidr_block      = var.subnet_cidr_block
  vpc_id                 = aws_vpc.app-vpc.id
  availability_zone      = var.availability_zone
  environment            = var.environment
  default_route_table_id = aws_vpc.app-vpc.default_route_table_id
}

module "app-webserver" {
  source            = "./modules/webserver"
  vpc_id            = aws_vpc.app-vpc.id
  my_ip             = var.my_ip
  availability_zone = var.availability_zone
  environment       = var.environment
  public_key_file   = file(var.public_key_file)
  instance_type     = var.instance_type
  subnet_id         = module.app-subnet.subnet.id
  image_name        = var.image_name
}
