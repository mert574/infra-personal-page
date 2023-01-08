provider "aws" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "app-vpc"
  cidr = var.vpc_cidr_block

  azs             = [var.availability_zone]
  public_subnets  = [var.subnet_cidr_block]

  public_subnet_tags = {
    Name = "${var.environment}-subnet"
  }

  tags = {
    Name = "${var.environment}-app-vpc"
  }
}

module "app-webserver" {
  source            = "./modules/webserver"
  vpc_id            = module.vpc.vpc_id
  my_ip             = var.my_ip
  availability_zone = var.availability_zone
  environment       = var.environment
  public_key_file   = file(var.public_key_file)
  instance_type     = var.instance_type
  subnet_id         = module.vpc.public_subnets[0]
  image_name        = var.image_name
}
