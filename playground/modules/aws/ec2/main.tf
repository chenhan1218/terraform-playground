module "security_group" {
  source = "../vpc/security_group"
}

module "aws" {
  source = "../"
}

resource "aws_launch_template" "this" {
  name                   = var.name
  image_id               = var.image_id
  instance_type          = var.instance_type
  key_name               = module.aws.key_pair.default.name
  vpc_security_group_ids = [module.security_group.id]
  block_device_mappings {
    device_name = "/dev/sda2"

    ebs {
      delete_on_termination = true
      volume_size           = 20
      volume_type           = "gp3"
    }
  }

  instance_market_options {
    market_type = "spot"
    spot_options {
      spot_instance_type = "one-time"
    }
  }
  tag_specifications {
    resource_type = "instance"

    tags = {
      name        = "instance-${var.name}"
      Terraform   = "true"
      Environment = "dev"
    }
  }
  tags = {
    name        = "launch-template-${var.name}"
    Terraform   = "true"
    Environment = "dev"
  }

  #  user_data
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"
  launch_template = {
    name = aws_launch_template.this.name
  }
  depends_on = [aws_launch_template.this]
  # TODO
  # subnet_id
  associate_public_ip_address = true
}
