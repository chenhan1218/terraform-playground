terraform {
  backend "s3" {
    bucket  = "chenhan-terraform-playground"
    key     = "playground/chenhan-staging"
    profile = "chenhan"
    region  = "ap-northeast-1"
  }
}

provider "aws" {
  profile = "chenhan"
  region  = "ap-northeast-1"
}

locals {
  instance_count = 1
  instance_type  = "t3a.nano"
  name           = "chenhan-staging"
  instance_names = toset(["one"])
}

provider "random" {}

resource "random_pet" "name" {}

module "aws" {
  source = "../modules/aws"
}

resource "random_id" "server" {
  for_each    = local.instance_names
  byte_length = 4
}

resource "aws_launch_template" "this" {
  for_each = local.instance_names

  name                   = "launch-template-${each.key}"
  image_id               = data.aws_ami.latest-ubuntu.id
  instance_type          = local.instance_type
  key_name               = module.aws.key_pair.default.name
  vpc_security_group_ids = [aws_security_group.dev.id]

  instance_market_options {
    market_type = "spot"
    spot_options {
      spot_instance_type = "one-time"
    }
  }
  tag_specifications {
    resource_type = "instance"

    tags = {
      name        = "instance-${each.key}"
      Terraform   = "true"
      Environment = "dev"
    }
  }
  tags = {
    name        = "launch-template-${each.key}"
    Terraform   = "true"
    Environment = "dev"
  }
}

data "aws_ami" "latest-ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_spot_instance_request" "cheap_worker" {
  ami                         = data.aws_ami.latest-ubuntu.id
  wait_for_fulfillment        = true
  instance_type               = local.instance_type
  vpc_security_group_ids      = [aws_security_group.dev.id]
  spot_type                   = "one-time"
  associate_public_ip_address = true

  tags = {
    Name = "CheapWorker"
  }
  key_name = module.aws.key_pair.default.name
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = local.instance_names
  launch_template = {
    name = "launch-template-${each.key}"
  }
  depends_on = [aws_launch_template.this]
  associate_public_ip_address = true
}

# resource "aws_instance" "this" {
#   ami                    = "ami-036d0684fc96830ca"
#   instance_type          = local.instance_type
#   vpc_security_group_ids = [aws_security_group.this-sg.id]
#   tags = {
#     Name = "${local.name}-${random_pet.name.id}"
#   }
#   key_name = module.aws.key_pair.default.name
# }

resource "aws_security_group" "dev" {
  name = "${local.name}-sg-dev"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}
