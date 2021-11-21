output "domain-name" {
  # value = aws_instance.this.public_dns
  value = aws_spot_instance_request.cheap_worker.public_dns
}

output "application-url" {
  # value = "${aws_instance.this.public_dns}/index.php"
  value = "${aws_spot_instance_request.cheap_worker.public_dns}/index.php"
}
