output "domain-name" {
  value = {
    for k, v in module.ec2_instance : k => v.public_dns
  }
}

output "spot-domain-name" {
  value = aws_spot_instance_request.cheap_worker.public_dns
}
