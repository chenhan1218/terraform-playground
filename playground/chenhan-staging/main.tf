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
  instances      = toset(["one"])
}

data "aws_ami" "latest_ubuntu" {
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

provider "random" {}

resource "random_pet" "name" {}

module "ec2" {
  source = "../modules/aws/ec2"

  image_id = data.aws_ami.latest_ubuntu.id
  for_each = local.instances
  name     = each.key
}

module "aws" {
  source = "../modules/aws"
}

module "aws_security_group" {
  source = "../modules/aws/vpc/security_group"
}

resource "random_id" "server" {
  # TODO
  # keeper
  for_each    = local.instances
  byte_length = 4
}


resource "aws_spot_instance_request" "cheap_worker" {
  # ami                         = local.ami_id
  ami                    = data.aws_ami.latest_ubuntu.id
  wait_for_fulfillment   = true
  instance_type          = local.instance_type
  vpc_security_group_ids = [module.aws_security_group.id]
  # [module.aws_security_group.dev.id]
  spot_type                   = "one-time"
  associate_public_ip_address = true

  tags = {
    Name = "CheapWorker"
  }
  key_name = module.aws.key_pair.default.name
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

