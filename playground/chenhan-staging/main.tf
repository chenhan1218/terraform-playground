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
}

locals {
  name = "chenhan-staging"
}

provider "random" {}

resource "random_pet" "name" {}

module "aws" {
  source = "../modules/aws"
}

resource "aws_spot_instance_request" "cheap_worker" {
  ami                    = "ami-036d0684fc96830ca"
  instance_type          = local.instance_type
  vpc_security_group_ids = [aws_security_group.this-sg.id]
  # spot_type = "one-time"
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

resource "aws_security_group" "this-sg" {
  name = "${local.name}-${random_pet.name.id}-sg"
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
}
