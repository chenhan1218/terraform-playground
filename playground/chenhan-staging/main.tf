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
  instances      = toset(["one", "awx-testing"])
}

provider "random" {}

resource "random_pet" "name" {}

# module "vpc_tokyo" {
#   source = "terraform-aws-modules/vpc/aws"

#   name = "vpc_tokyo"
#   cidr = "10.0.0.0/16"

#   azs = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
#   azs = data.aws_availability_zones.available.names
#   private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#   public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

#   enable_nat_gateway = true
#   enable_vpn_gateway = true

#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#   }
# }

# module "vpc_singapore" {
#   source = "terraform-aws-modules/vpc/aws"

#   name = "vpc_singapore"
#   cidr = "10.0.0.0/16"

#   azs             = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
#   private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#   public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

#   enable_nat_gateway = true
#   enable_vpn_gateway = true

#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#   }
# }

module "ec2" {
  source = "../modules/aws/ec2"

  image_id           = module.ami.latest_ubuntu_ami_id
  for_each           = local.instances
  security_group_ids = [module.aws_security_group.id]
  name               = each.key

  # subnet_id = module.vpc_tokyo.public_subnets[0]
}

module "aws" {
  source = "../modules/aws"
}

module "aws_security_group" {
  source = "../modules/aws/vpc/security_group"
  # vpc_id = module.vpc_tokyo.vpc_id
}

module "ami" {
  source = "../modules/aws/ami"
}

resource "random_id" "server" {
  # TODO
  # keeper
  for_each    = local.instances
  byte_length = 4
}


resource "aws_spot_instance_request" "cheap_worker" {
  ami                         = module.ami.latest_ubuntu_ami_id
  wait_for_fulfillment        = true
  instance_type               = local.instance_type
  vpc_security_group_ids      = [module.aws_security_group.id]
  spot_type                   = "one-time"
  associate_public_ip_address = true
  # subnet_id                   = module.vpc_tokyo.public_subnets[0]

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

