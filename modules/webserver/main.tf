data "aws_ami" "amzn2-ami" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = [var.image_name] # "amzn2-ami-hvm-*-x86_64-gp2"
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "app-sg" {
  vpc_id = var.vpc_id

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
    Name = "${var.environment}-app-sg"
  }
}

resource "aws_key_pair" "app-kp" {
  key_name_prefix = "app-kp-"
  public_key = var.public_key_file
}

resource "aws_instance" "app-server" {
  instance_type               = var.instance_type
  availability_zone           = var.availability_zone
  ami                         = data.aws_ami.amzn2-ami.image_id
  associate_public_ip_address = true

  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.app-sg.id]
  key_name                    = aws_key_pair.app-kp.key_name

  user_data = file("entry-script.sh")
  user_data_replace_on_change = true

  provisioner "local-exec" {
    command = "echo Instance IP: ${self.public_ip}"
  }

  tags = {
    Name = "${var.environment}-app-instance"
  }
}
