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

provider "random" {}

resource "random_pet" "name" {}

module "aws" {
  source="../modules/aws"
}

resource "aws_instance" "this" {
  ami                    = "ami-06cd52961ce9f0d85"
  instance_type          = local.instance_type
  user_data              = file("init-script.sh")
  vpc_security_group_ids = [aws_security_group.this-sg.id]
  tags = {
    Name = random_pet.name.id
  }
  key_name      = module.aws.key_pair.default.name
}

resource "aws_security_group" "this-sg" {
  name = "${random_pet.name.id}-sg"
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
